## Align CLAMP input with medication attribute results

```
library(readr)
library(IRanges)
library(reshape)

eol.size <- 1

submitted.strings <-
  read_delim(
    "C:/ClampWin_1.5.0/workspace/MyPipeline/medication-attribute/Data/Input/for_clamp_10000.txt",
    "\t",
    escape_double = FALSE,
    col_names = FALSE,
    locale = locale(encoding = "WINDOWS-1252"),
    trim_ws = FALSE
  )

submitted.strings$nchar <- nchar(submitted.strings$X1)
submitted.strings$padded <- submitted.strings$nchar + eol.size

temp <- c(0, submitted.strings$padded)
temp <- temp[1:nrow(submitted.strings)]
submitted.strings$start <- temp
submitted.strings$start <- cumsum(submitted.strings$start)
submitted.strings$end <-
  submitted.strings$start + submitted.strings$nchar
submitted.strings$submission.row <- 1:nrow(submitted.strings)

submitted.as.subject <-
  IRanges(submitted.strings$start, submitted.strings$end)

clamp.output <-
  read_delim(
    "C:/ClampWin_1.5.0/workspace/MyPipeline/medication-attribute/Data/Output/for_clamp_10000.txt",
    "\t",
    escape_double = FALSE,
    trim_ws = TRUE
  )

clamp.output.as.query <-
  IRanges(clamp.output$Start, clamp.output$End)

found.overlaps <-
  as.data.frame(findOverlaps(clamp.output.as.query, submitted.as.subject, type = "within"))

clamp.output <- cbind.data.frame(clamp.output, found.overlaps)

merged.overlaps <-
  merge(
    x = clamp.output,
    y = submitted.strings,
    by.x = "subjectHits",
    by.y = "submission.row",
    all.x = TRUE
  )
merged.overlaps$mo.row <- 1:nrow(merged.overlaps)

split.cuis <- strsplit(merged.overlaps$CUI, ", ")
names(split.cuis) <- merged.overlaps$mo.row

rxn.splits <- lapply(names(split.cuis), function(current.cui.val) {
  current.cui <- split.cuis[[current.cui.val]]
  current.cui <- current.cui[grepl(pattern = "=", current.cui)]
  current.cui <- strsplit(current.cui, "=")
  temp1 <- unlist(current.cui)
  if (!is.null(temp1)) {
    temp2 <- matrix(temp1, ncol = 2, byrow = TRUE)
    temp2 <- as.data.frame(temp2)
    names(temp2) <- c("specificity", "rxn.val")
    temp2$rxn.val <-
      gsub(pattern = "\\[",
           replacement = "",
           x = temp2$rxn.val)
    temp2$rxn.val <-
      gsub(pattern = "\\]",
           replacement = "",
           x = temp2$rxn.val)
    temp2$inpidx <- current.cui.val
    return(temp2)
  }
})
rxn.splits <- do.call(rbind.data.frame, rxn.splits)
rxn.splits <-
  cast(data = rxn.splits,
       formula = inpidx ~ specificity,
       value = "rxn.val")

rxn.splits[] <- lapply(rxn.splits[], as.character)
rxn.splits[] <- lapply(rxn.splits[], as.numeric)

merged.overlaps <-
  merge(
    x = merged.overlaps,
    y = rxn.splits,
    by.x = "queryHits",
    by.y = "inpidx",
    all.x = TRUE
  )

minimal.mo <-
  unique(merged.overlaps[(!(is.na(merged.overlaps$RxNorm))), c("Semantic",
                                                               "Entity",
                                                               "X1",
                                                               "Generic",
                                                               "RxNorm")])
```

How many inputs?  How many got an RxNorm mapping?


```
> print(length(unique(submitted.strings$X1)))
[1] 9507
> print(length(unique(minimal.mo$X1)))
[1] 5028

```

The CLAMP RxNrm mappings appears to have very high precision.  However, No CLAMP RxNorm mapping is available for half of the "medications" that already had RxNorm assignments (by Penn Med School scientists).  Show a sample:

```
> temp <- setdiff(submitted.strings$X1, minimal.mo$X1)
> temp <- sort(sample(temp, 20, replace = FALSE))
> no.CLAMP.mapping <- penn.med.mappings[penn.med.mappings$MedicationName %in% temp , ]


MedicationName | RXNORM_CODE | RXNORM_CODE_LEVEL
-- | -- | --
ALECTINIB HCL 150 MG PO CAPS | 1727479 | MED_FORM_STRENGTH
ALECTINIB HCL 150 MG PO CAPS | 1727454 | MED_ONLY
ALECTINIB HCL 150 MG PO CAPS | 1727455 | MED_ONLY
AM/PM PERIMENOPAUSE FORMULA PO | - | -
AMBOPHEN SYRP 12.5-10 MG/5ML OR | 702131 | MED_FORM_STRENGTH
AMBOPHEN SYRP 12.5-10 MG/5ML OR | 755303 | MED_FORM_STRENGTH
AMBOPHEN SYRP 12.5-10 MG/5ML OR | 996764 | MED_FORM_STRENGTH
AMBOPHEN SYRP 12.5-10 MG/5ML OR | 996768 | MED_FORM_STRENGTH
AMBOPHEN SYRP 12.5-10 MG/5ML OR | 1294356 | MED_FORM_STRENGTH
AMBOPHEN SYRP 12.5-10 MG/5ML OR | 2670 | MED_ONLY
AMBOPHEN SYRP 12.5-10 MG/5ML OR | 19759 | MED_ONLY
AMBOPHEN SYRP 12.5-10 MG/5ML OR | 214323 | MED_ONLY
AMBOPHEN SYRP 12.5-10 MG/5ML OR | 215202 | MED_ONLY
BYSTOLIC 5 MG PO TABS | 387013 | MED_FORM_STRENGTH
BYSTOLIC 5 MG PO TABS | 751623 | MED_FORM_STRENGTH
BYSTOLIC 5 MG PO TABS | 31555 | MED_ONLY
BYSTOLIC 5 MG PO TABS | 751613 | MED_ONLY
CALCITONIN (SALMON) INJECTION | - | -
CYCLOPHOSPHAMIDE IVPB 250ML NSS (500MG   VIAL) | - | -
DELFLEX-LM/4.25% DEXTROSE 485 MOSM/L   INTRAPERITON SOLN | 799999 | MED_FORM_STRENGTH
DELFLEX-LM/4.25% DEXTROSE 485 MOSM/L   INTRAPERITON SOLN | 1901 | MED_ONLY
DELFLEX-LM/4.25% DEXTROSE 485 MOSM/L   INTRAPERITON SOLN | 4850 | MED_ONLY
DELFLEX-LM/4.25% DEXTROSE 485 MOSM/L   INTRAPERITON SOLN | 6579 | MED_ONLY
DELFLEX-LM/4.25% DEXTROSE 485 MOSM/L   INTRAPERITON SOLN | 9863 | MED_ONLY
DELFLEX-LM/4.25% DEXTROSE 485 MOSM/L   INTRAPERITON SOLN | 114202 | MED_ONLY
DELFLEX-LM/4.25% DEXTROSE 485 MOSM/L   INTRAPERITON SOLN | 1007046 | MED_ONLY
DELFLEX-LM/4.25% DEXTROSE 485 MOSM/L   INTRAPERITON SOLN | 1087647 | MED_ONLY
EXU-DRY PADDED NECK 6"X25" EX | - | -
GNP COLD HEAD CONGESTION 5-10-200-325 MG   PO TABS | 636588 | MED_FORM_STRENGTH
GNP COLD HEAD CONGESTION 5-10-200-325 MG   PO TABS | 1110988 | MED_FORM_STRENGTH
GNP COLD HEAD CONGESTION 5-10-200-325 MG   PO TABS | 161 | MED_ONLY
GNP COLD HEAD CONGESTION 5-10-200-325 MG   PO TABS | 3289 | MED_ONLY
GNP COLD HEAD CONGESTION 5-10-200-325 MG   PO TABS | 5032 | MED_ONLY
GNP COLD HEAD CONGESTION 5-10-200-325 MG   PO TABS | 8163 | MED_ONLY
GNP COLD HEAD CONGESTION 5-10-200-325 MG   PO TABS | 689776 | MED_ONLY
INSULIN SYRINGE-NEEDLE U-100 31G X   3/8" 0.5 ML MISC | - | -
KADIAN 200 MG PO CP24 | 152778 | MED_FORM_STRENGTH
KADIAN 200 MG PO CP24 | 248606 | MED_FORM_STRENGTH
KADIAN 200 MG PO CP24 | 700412 | MED_FORM_STRENGTH
KADIAN 200 MG PO CP24 | 892643 | MED_FORM_STRENGTH
KADIAN 200 MG PO CP24 | 892645 | MED_FORM_STRENGTH
KADIAN 200 MG PO CP24 | 894941 | MED_FORM_STRENGTH
KADIAN 200 MG PO CP24 | 7052 | MED_ONLY
KADIAN 200 MG PO CP24 | 203240 | MED_ONLY
KCL IN DEXTROSE-NACL 20-5-0.225 MEQ/L-%-%   IV SOLN [COMPILED RECORD] [AGE ADULT] [10/22/2017 10:22 PM] | 664703 | MED_FORM_STRENGTH
KCL IN DEXTROSE-NACL 20-5-0.225 MEQ/L-%-%   IV SOLN [COMPILED RECORD] [AGE ADULT] [10/22/2017 10:22 PM] | 1863973 | MED_FORM_STRENGTH
KCL IN DEXTROSE-NACL 20-5-0.225 MEQ/L-%-%   IV SOLN [COMPILED RECORD] [AGE ADULT] [10/22/2017 10:22 PM] | 1863975 | MED_FORM_STRENGTH
KCL IN DEXTROSE-NACL 20-5-0.225 MEQ/L-%-%   IV SOLN [COMPILED RECORD] [AGE ADULT] [10/22/2017 10:22 PM] | 4850 | MED_ONLY
KCL IN DEXTROSE-NACL 20-5-0.225 MEQ/L-%-%   IV SOLN [COMPILED RECORD] [AGE ADULT] [10/22/2017 10:22 PM] | 8591 | MED_ONLY
KCL IN DEXTROSE-NACL 20-5-0.225 MEQ/L-%-%   IV SOLN [COMPILED RECORD] [AGE ADULT] [10/22/2017 10:22 PM] | 9863 | MED_ONLY
KCL IN DEXTROSE-NACL 20-5-0.225 MEQ/L-%-%   IV SOLN [COMPILED RECORD] [AGE ADULT] [10/22/2017 10:22 PM] | 216554 | MED_ONLY
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 578871 | MED_FORM_STRENGTH
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 748382 | MED_FORM_STRENGTH
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 753542 | MED_FORM_STRENGTH
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 1359023 | MED_FORM_STRENGTH
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 1359027 | MED_FORM_STRENGTH
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 4124 | MED_ONLY
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 7514 | MED_ONLY
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 24941 | MED_ONLY
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 384410 | MED_ONLY
MICROGESTIN FE 1.5/30 1.5-30 MG-MCG PO   TABS | 466546 | MED_ONLY
NASAL DILATORS SMALL/MEDIUM STRP | - | -
PAIN RELIEVING 10 % EX CREA | 313518 | MED_FORM_STRENGTH
PAIN RELIEVING 10 % EX CREA | 416377 | MED_FORM_STRENGTH
PAIN RELIEVING 10 % EX CREA | 38866 | MED_ONLY
PEDITRACE IV SOLN | - | -
SCALP TREATMENT 10-10 % EX KIT | 793885 | MED_FORM_STRENGTH
SCALP TREATMENT 10-10 % EX KIT | 904617 | MED_FORM_STRENGTH
SCALP TREATMENT 10-10 % EX KIT | 10169 | MED_ONLY
SCALP TREATMENT 10-10 % EX KIT | 11002 | MED_ONLY
SHOBEN SOLN 10 MG/ML IM | 207810 | MED_FORM_STRENGTH
SHOBEN SOLN 10 MG/ML IM | 991065 | MED_FORM_STRENGTH
SHOBEN SOLN 10 MG/ML IM | 3361 | MED_ONLY
TH NIACIN FLUSH FREE 500 MG PO CAPS | 245856 | MED_FORM_STRENGTH
TH NIACIN FLUSH FREE 500 MG PO CAPS | 5833 | MED_ONLY
TRIACTIN 1-6.25 MG/5ML OR SYRP | 755165 | MED_FORM_STRENGTH
TRIACTIN 1-6.25 MG/5ML OR SYRP | 755543 | MED_FORM_STRENGTH
TRIACTIN 1-6.25 MG/5ML OR SYRP | 2400 | MED_ONLY
TRIACTIN 1-6.25 MG/5ML OR SYRP | 8132 | MED_ONLY
TRIACTIN 1-6.25 MG/5ML OR SYRP | 8175 | MED_ONLY
TRIACTIN 1-6.25 MG/5ML OR SYRP | 9009 | MED_ONLY
TRIACTIN 1-6.25 MG/5ML OR SYRP | 214394 | MED_ONLY
TRIACTIN 1-6.25 MG/5ML OR SYRP | 220423 | MED_ONLY
TRIACTIN 1-6.25 MG/5ML OR SYRP | 220426 | MED_ONLY


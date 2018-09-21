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

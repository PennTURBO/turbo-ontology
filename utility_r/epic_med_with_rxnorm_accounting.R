options(java.parameters = "- Xmx8g")

library(readxl)
library(readr)
library(xlsx)
library(caret)

setwd("c:/Users/Mark Miller/Desktop/med_authorities/")

epic.auth.fn <- "EPIC medication hierarchy.xlsx"
epic.auth <- read_xlsx(epic.auth.fn)

epic2chebi_analgesics <-
  read_csv("C:/Users/Mark Miller/Downloads/epic2chebi_analgesics.csv")

merged <- merge(
  x = epic.auth,
  y = epic2chebi_analgesics,
  by.x = "MEDICATION_ID",
  by.y = "epicMedId",
  all = TRUE
)

merged <- merged[merged$RXNORM_CODE != "-" , ]

# c("MEDICATION_ID", "MedicationName", "GENERIC_NAME", "STRENGTH",
#   "FORM", "ROUTE",
# "PharmacyClass", "PharmacySubClass", "TherapyClass",
#
#   "RECORD_STATE", "RXNORM_CODE", "RXNORM_CODE_LEVEL")

blankcounts <- lapply(epic.auth[], function(one.col) {
  inner <- one.col == "-"
  return(sum(inner))
})
blankcounts <-
  cbind.data.frame(names(blankcounts), as.numeric(blankcounts))

levelcounts  <- lapply(epic.auth[], function(one.col) {
  inner <- length(unique(one.col))
  return(sum(inner))
})
levelcounts <-
  cbind.data.frame(names(levelcounts), as.numeric(levelcounts))

drugcounts  <- table(merged$chebilab)
drugcounts <-
  cbind.data.frame(names(drugcounts), as.numeric(drugcounts))


# "PharmacyClass", "PharmacySubClass", "TherapyClass",
topclasscounts  <- table(merged$PharmacyClass)
topclasscounts <-
  cbind.data.frame(names(topclasscounts), as.numeric(topclasscounts))


subclasscounts  <- table(merged$PharmacySubClass)
subclasscounts <-
  cbind.data.frame(names(subclasscounts), as.numeric(subclasscounts))


therapycounts  <- table(merged$TherapyClass)
therapycounts <-
  cbind.data.frame(names(therapycounts), as.numeric(therapycounts))



crosscheck <-
  as.data.frame.matrix(table(merged$PharmacySubClass, merged$irlab))

temp <-
  unique(tolower(c(
    unique(merged$PharmacyClass),
    unique(merged$PharmacySubClass),
    unique(merged$TherapyClass)
  )))
temp.flag  <-
  grepl(pattern = "analgesic",
        x = temp,
        ignore.case = TRUE)
temp <- cbind.data.frame(temp, temp.flag)

all.greppable.cats <-
  c(
    "analgesics-nonnarcotic",
    "analgesics-narcotic",
    "analgesics other",
    "analgesic combinations",
    "otic analgesics",
    "urinary analgesics",
    "analgesics - topical",
    "analgesics-peptide channel blockers",
    "analgesics - anti-inflammatory combinations",
    "analgesics & anesthetics"
  )

allowed <-
  c(
    "analgesics-nonnarcotic",
    "analgesics-narcotic",
    "analgesics other",
    "analgesic combinations",
    "otic analgesics",
    "urinary analgesics",
    "analgesics - topical",
    "analgesics - anti-inflammatory combinations"
  )

omitted <- setdiff(all.greppable.cats, allowed)



parent.flag <-
  tolower(as.character(merged$PharmacyClass)) %in% allowed

sub.flag <-
  tolower(as.character(merged$PharmacySubClass)) %in% allowed

therapy.flag <-
  tolower(as.character(merged$TherapyClass)) %in% allowed

any.flag <- cbind.data.frame(parent.flag, sub.flag, therapy.flag)
any.flag <- rowSums(any.flag)
any.flag <- any.flag > 0

merged$epic.analgesic.flag <- any.flag

merged$turbo.analgesic.flag <- !is.na(merged$irlab)

merged$mismatch.bool <-
  merged$epic.analgesic.flag != merged$turbo.analgesic.flag

merged$mismatch.text <- 'consensus'
merged$mismatch.text[merged$mismatch.bool &
                       merged$epic.analgesic.flag] <- 'EPIC only'
merged$mismatch.text[merged$mismatch.bool &
                       merged$turbo.analgesic.flag] <- 'TURBO only'

# which?
for.caret <-
  table(merged$epic.analgesic.flag, merged$turbo.analgesic.flag)
sensitivity(for.caret)
specificity(for.caret)
for.caret <-
  table(merged$turbo.analgesic.flag, merged$epic.analgesic.flag)
sensitivity(for.caret)
specificity(for.caret)



check.by.subclass <-
  as.data.frame.matrix(table(merged$PharmacySubClass , merged$mismatch.text, useNA = 'ifany'))


check.by.chebi.comp <-
  as.data.frame.matrix(table(merged$chebilab , merged$mismatch.text, useNA = 'ifany'))

# save.image("210809201015.Rdata")

epic.detective <-
  merged[merged$mismatch.text == "EPIC only" &
           merged$PharmacySubClass == "Analgesics Other",]
epic.detective <- table(epic.detective$RXNORM_CODE)
epic.detective <-
  cbind.data.frame(names(epic.detective), as.numeric(epic.detective))

turbo.detective <- table(merged$chebilab[merged$mismatch.text == "TURBO only"])
turbo.detective <-
  cbind.data.frame(names(turbo.detective), as.numeric(turbo.detective))


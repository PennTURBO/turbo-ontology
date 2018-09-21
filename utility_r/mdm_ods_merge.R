options(java.parameters = "- Xmx8g")

library(readxl)
library(readr)
library(xlsx)
setwd("c:/Users/Mark Miller/Desktop/med_authorities/")


mdm.auth.fn <- "mdm_r_medication_180917.csv"
mdm.auth <-
  read_csv(mdm.auth.fn, locale = locale(encoding = "WINDOWS-1252"))
dim(mdm.auth)

ods.auth.fn <- "ods_r_medication_source_180917.csv"
ods.auth <-
  read_csv(ods.auth.fn, locale = locale(encoding = "WINDOWS-1252"))
dim(ods.auth)

ods.auth.minimal <-
  ods.auth[, c("PK_MEDICATION_ID", "FULL_NAME", "SOURCE_CODE")]


merged <-
  merge(
    x = mdm.auth,
    y = ods.auth.minimal,
    by = "PK_MEDICATION_ID",
    all = TRUE,
    suffixes = c(".mdm", ".ods")
  )

merged$same.text = merged$FULL_NAME.mdm == merged$FULL_NAME.ods
merged <-
  merged[, c(
    "PK_MEDICATION_ID",
    "FULL_NAME.mdm",
    "PHARMACY_CLASS",
    "SIMPLE_GENERIC_NAME",
    "GENERIC_NAME",
    "THERAPEUTIC_CLASS",
    "PHARMACY_SUBCLASS",
    "AMOUNT",
    "FORM",
    "ROUTE_DESCRIPTION",
    "ROUTE_TYPE",
    "CONTROLLED_MED_YN",
    "DEA_CLASS",
    "RECORD_STATE",
    "FK_3M_NCID_ID",
    "RXNORM",
    "RXNORM_DEFINITION",
    "MDM_LAST_UPDATE_DATE",
    "MDM_INSERT_UPDATE_FLAG",
    "SOURCE_CODE",
    "same.text"
  )]


names(merged) <- c(
  "PK_MEDICATION_ID",
  "FULL_NAME",
  "PHARMACY_CLASS",
  "SIMPLE_GENERIC_NAME",
  "GENERIC_NAME",
  "THERAPEUTIC_CLASS",
  "PHARMACY_SUBCLASS",
  "AMOUNT",
  "FORM",
  "ROUTE_DESCRIPTION",
  "ROUTE_TYPE",
  "CONTROLLED_MED_YN",
  "DEA_CLASS",
  "RECORD_STATE",
  "FK_3M_NCID_ID",
  "RXNORM",
  "RXNORM_DEFINITION",
  "MDM_LAST_UPDATE_DATE",
  "MDM_INSERT_UPDATE_FLAG",
  "ods.SOURCE_CODE",
  "mdm.ods.same.FULL_NAME"
)

write.csv(x = merged, file = "mdm_ods_merged_meds.csv", row.names = FALSE)

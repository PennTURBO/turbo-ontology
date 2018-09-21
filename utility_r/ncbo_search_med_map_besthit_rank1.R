library(plyr)
library(dplyr)
library(httr)
library(magrittr)
library(readr)
library(rjson)
library(tidytext)
library(tm)
library(stringdist)

target.coverage <- 1.0

wes_pds_enc__med_order <-
  unique(read.csv(
    "C:/Users/Mark Miller/Desktop/icanspell/wes_pds_enc__med_order.csv"
  ))

wes_pds__med_standard <-
  unique(
    read.csv(
      "C:/Users/Mark Miller/Desktop/icanspell/wes_pds__med_standard.csv",
      header = TRUE
    )
  )

order.with.standard <- merge(
  x = wes_pds_enc__med_order,
  y = wes_pds__med_standard,
  by.x = "FK_MEDICATION_ID",
  by.y = "PK_MEDICATION_ID",
  all = TRUE
)

# a big ordername/standard fullname discrepancy can be traced to "IMS MIXTURE"
# flag orders that ahve that value in one but not the other slot


one.imsmix <-
  order.with.standard$PK_ORDER_MED_ID[order.with.standard$ORDER_NAME == "IMS MIXTURE" |
                                        order.with.standard$FULL_NAME == "IMS MIXTURE"]

both.imsmix <-
  order.with.standard$PK_ORDER_MED_ID[order.with.standard$ORDER_NAME == "IMS MIXTURE" &
                                        order.with.standard$FULL_NAME == "IMS MIXTURE"]

imsmix.mismatch <- setdiff(one.imsmix, both.imsmix)

order.with.standard$imsmix.mismatch <- FALSE
order.with.standard$imsmix.mismatch[order.with.standard$PK_ORDER_MED_ID %in% imsmix.mismatch] <-
  TRUE

# ge the distances between the ordernames and standard fullnames
# for future followup


ord.full.stringdist <-
  stringdist::stringdist(tolower(as.character(order.with.standard$ORDER_NAME)),
                         tolower(as.character(order.with.standard$FULL_NAME)), method = "cosine")

order.with.standard$stringdist <- ord.full.stringdist

# find those standard fullnames that accoutn for 90% of the orders
# 710 out of 4101 standard fullnames in this case

temp <- table(order.with.standard$FULL_NAME)
temp <- cbind.data.frame(names(temp), as.numeric(temp))
names(temp) <- c("FULL_NAME", "count")

temp <- temp[order(temp$count, decreasing = TRUE), ]
temp$cumsum <- cumsum(temp$count)
temp$cumpct <- temp$cumsum / sum(temp$count)
rownames(temp) <- 1:nrow(temp)

plot(temp$cumpct, type = "l")

# had wanted to programatically find the inflection point

# lastquery <- which.min(abs(temp$cumpct - target.coverage))
# queries <-
#   as.character(temp$FULL_NAME[as.numeric(rownames(temp)) < lastquery])


queries <-
  as.character(temp$FULL_NAME)

# fix soem of the UPHS idosyncratic langage to better match terms from preferred ontologies



queries <- cbind.data.frame(queries, tolower(queries))

names(queries) <- c("FULL_NAME", "FULL_NAME.lc")

queries$expanded <-
  stringr::str_replace_all(
    queries$FULL_NAME.lc,
    c(
      "\\bpo\\b" = "oral",
      "\\bor\\b" = "oral",
      "\\btabs\\b" = "tablet",
      "\\bcaps\\b" = "capsule",
      "\\bsoln\\b" = "solution",
      "\\bsopn\\b" = "solution",
      "\\bsolr\\b" = "solution",
      "\\bsyrp\\b" = "syrup",
      "\\bsusp\\b" = "suspension",
      "\\ber\\b" = "extended release",
      "\\bsimeth\\b" = "simethicone",
      "\\bsupp\\b" = "suppository",
      "\\bunits\\b" = "unit",
      "\\bdss\\b" = "docusate",
      "\\bsubl\\b" = "sublingual",
      "\\btbec\\b" = "enteric coated tablet",
      "\\btbcr\\b" = "extended release tablet",
      "\\baers\\b" = "aerosol",
      "\\baepb\\b" = "aerosol powder",
      "\\bcpdr\\b" = "delayed release capsule",
      "\\binjection_\\b" = "injectable solution",
      "\\benem\\b" = "enema",
      "\\bivpb\\b" = "injectable solution",
      "\\bmonohyd\\b" = "monohydrate",
      "\\bex\\b" = "external",
      "\\bcrea\\b" = "cream",
      "\\btmp\\b" = "trimethoprim",
      "\\bsmz\\b" = "sulfamethoxazole",
      "\\boint\\b" = "ointment",
      "\\bstrp\\b" = "strip",
      "\\bliqd\\b" = "liquid",
      "\\bsc\\b" = "",
      "\\bcorrection\\b" = "",
      "\\bdosing\\b" = "",
      "\\bcrys\\b" = "",
      "\\btbdp\\b" = "",
      "\\bpush\\b" = ""
    )
  )

queries <- queries[order(queries$expanded), ]

# search the tidied standard fullnames agaisnt all ontologies in the BioPortal

### long term goals
# check the resutls agaisnt the exisiting RxNORM annotations...
#   may need to tolerate orders that are more specific
# where possible, map anything that isn't already from RxNORM to RxNORM
# then map from RxNORM to realist ontologies like DRON and ChEBI

result.list <- lapply(queries$expanded, function(current.order) {
  print(current.order)
  encoded.order <-
    URLencode(current.order, reserved = TRUE)
  print(encoded.order)
  composed.query <- paste0(
    "https://data.bioontology.org/search?",
    "apikey=9cf735c3-a44a-404f-8b2f-c49d48b2b8b2&",
    "q=",
    encoded.order,
    "&pagesize=10"
  )
  print(composed.query)
  temp <-
    rawToChar(httr::GET(composed.query)$content)
  temp <- fromJSON(temp)
  return(temp)
})

names(result.list) <- queries$expanded

save(result.list, file = "coverage90.Rdata")

###   ###   ###

load(file = "coverage90.Rdata")


backtrack <-
  lapply(queries$expanded, function(current.order) {
    print(current.order)
    corl <- result.list[[current.order]]
    # print(names(corl))
    # print(grepl(pattern = "collection", x = names(corl)))
    if ("collection" %in% names(corl) &&
        length(corl[["collection"]]) > 0) {
      # print(corl[["collection"]])
      # print(1)
      corl.coll <- corl[["collection"]]
      # print(2)
      # print(names(corl.coll))
      present.colls <-
        intersect(names(corl.coll),
                  c("prefLabel", "cui", "semanticType", "matchType", "@id"))
      # print(present.colls)
      corl.coll.selcols <-
        corl.coll[, present.colls]
      # print(3)
      corl.coll.links <- corl.coll[['links']]
      # print(4)
      corl.coll.links.ontology <- corl.coll.links[['ontology']]
      # print(5)
      corl.coll.selcols$ontology <- unlist(corl.coll.links.ontology)
      # print(6)
      corl.coll.selcols$hit.count <- nrow(corl.coll.selcols)
      # print(7)
      corl.coll.selcols$rank <- 1:nrow(corl.coll.selcols)
      corl.coll.selcols$order <- current.order
      # print(8)
      names(corl.coll.selcols) <-
        make.names(names(corl.coll.selcols))
      # print(9)
      # print(corl.coll.selcols)
      return(corl.coll.selcols)
    }
    
  })

result.frame <- plyr::rbind.fill(backtrack)
temp <- which(names(result.frame) == "X.id")
names(result.frame)[temp] <- "id"

distances <-
  apply(
    X = result.frame,
    MARGIN = 1,
    FUN = function(current.row) {
      pds.string <- tolower(as.character(current.row['order']))
      found.string <-
        tolower(as.character(current.row['prefLabel']))
      # print(pds.string)
      # print(found.string)
      one.dist <-
        stringdist(a = pds.string, b = found.string, method = "cosine")
      return(one.dist)
    }
  )

result.frame$stringdist <- distances



###   ###   ###

cuitemp <- unique(result.frame[, c("id", "cui")])
cuitemp <- cuitemp[cuitemp$cui != "NULL" , ]

cuitemp <- apply(
  cuitemp,
  MARGIN = 1,
  FUN = function(current.row) {
    my.id <- current.row[['id']]
    my.cuis <-
      strsplit(current.row[['cui']], ";")
    my.cuis <- my.cuis[[1]]
    listlen <- length(my.cuis)
    # print(my.cuis)
    temp <-
      cbind.data.frame("id" = rep(my.id, listlen), "cui" = my.cuis)
    # print(temp)
  }
)

cuitemp <- do.call(rbind.data.frame, cuitemp)
cuitemp[] <- lapply(cuitemp[], as.character)

sem.type.temp <-
  unique(result.frame[, c("id", "semanticType")])

sem.type.temp <-
  sem.type.temp[sem.type.temp$semanticType != "NULL" , ]

sem.type.temp <- apply(
  sem.type.temp,
  MARGIN = 1,
  FUN = function(current.row) {
    my.id <- current.row[['id']]
    my.types <-
      strsplit(current.row[['semanticType']], ";")
    my.types <- my.types[[1]]
    listlen <- length(my.types)
    # print(my.cuis)
    temp <-
      cbind.data.frame("id" = rep(my.id, listlen), "semanticType" = my.types)
    # print(temp)
  }
)

sem.type.temp <-
  do.call(rbind.data.frame, sem.type.temp)
sem.type.temp[] <- lapply(sem.type.temp[], as.character)

write.table(
  sem.type.temp,
  file = "med_standard_FULL_NAME_bioportal_search_semanticTypes_flippedranks_all100.txt",
  sep = "\t",
  col.names = TRUE,
  row.names = FALSE
)

result.frame <-
  result.frame[, c(
    "order",
    "prefLabel",
    "matchType",
    "id",
    "ontology",
    "hit.count",
    "rank",
    "stringdist"
  )]

write.table(
  result.frame,
  file = "med_standard_FULL_NAME_bioportal_search_flippedranks_all100_20180904_overnight.txt",
  sep = "\t",
  col.names = TRUE,
  row.names = FALSE
)


write.csv(
  result.frame,
  file = "med_standard_FULL_NAME_bioportal_search_flippedranks_all100_20180904_overnight.csv",
  row.names = FALSE
)

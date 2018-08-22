library(plyr)
library(dplyr)
library(stringdist)
library(stringr)
library(rjson)
library(tidytext)
library(inflection)

search.fraction <- 0.8
search.size <- NA

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

# get the distances between the ordernames and standard fullnames
# for future followup
ord.full.stringdist <-
  stringdist::stringdist(tolower(as.character(order.with.standard$ORDER_NAME)),
                         tolower(as.character(order.with.standard$FULL_NAME)), method = "cosine")

order.with.standard$stringdist <- ord.full.stringdist

# find those standard fullnames that accoutn for 90% of the orders
# 710 out of 4101 standard fullnames in this case

prominent.orders <- table(order.with.standard$FK_MEDICATION_ID)
prominent.orders <-
  cbind.data.frame(names(prominent.orders), as.numeric(prominent.orders))
names(prominent.orders) <- c("FK_MEDICATION_ID", "count")

prominent.orders <- merge(
  x = prominent.orders,
  y = wes_pds__med_standard[, c("PK_MEDICATION_ID", "FULL_NAME")],
  by.x = "FK_MEDICATION_ID",
  by.y = "PK_MEDICATION_ID",
  all = TRUE
)

prominent.orders <-
  prominent.orders[order(prominent.orders$count, decreasing = TRUE),]
prominent.orders$cumsum <- cumsum(prominent.orders$count)
prominent.orders$cumpct <-
  prominent.orders$cumsum / sum(prominent.orders$count)
rownames(prominent.orders) <- 1:nrow(prominent.orders)

plot(prominent.orders$cumpct, type = 'l')

lastquery <-
  which.min(abs(prominent.orders$cumpct - search.fraction))

prominent.orders$common.flag <-
  as.numeric(rownames(prominent.orders)) < lastquery

print(table(prominent.orders$common.flag))

expansion.rules <- c(
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

rules.export <-
  cbind.data.frame(names(expansion.rules), expansion.rules)
names(rules.export) <-
  c("pattern", "replacement")

write.table(
  rules.export,
  file = "med_map_expansions.txt",
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE,
  sep = "\t"
)


prominent.orders$FULL_NAME.lc <- tolower(prominent.orders$FULL_NAME)
prominent.orders$expanded <-
  str_replace_all(prominent.orders$FULL_NAME.lc, expansion.rules)

write.table(
  prominent.orders[, c("FK_MEDICATION_ID", "FULL_NAME", "expanded")],
  file = "med_standard_FULL_NAME_query_expansion.txt",
  sep = "\t",
  col.names = TRUE,
  row.names = FALSE
)



search.queries <-
  sort(prominent.orders$expanded[prominent.orders$common.flag])

if (is.na(search.size)) {
  search.size <- length(search.queries)
}

search.queries <- search.queries[1:search.size]


result.list <-
  lapply(search.queries, function(current.order) {
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

names(result.list) <- search.queries

result.frame <-
  lapply(search.queries, function(current.order) {
    print(current.order)
    current.result <-
      result.list[[current.order]]$collection
    temp <- current.result
    current.result.match <-
      lapply(temp, function(current.match) {
        current.prefLabel <- current.match$prefLabel
        current.cui <- current.match$cui
        current.semanticType <-
          current.match$semanticType
        current.matchType <-
          current.match$matchType
        current.id <- current.match[['@id']]
        current.ontology <-
          current.match$links$ontology
        return(
          list(
            order = current.order,
            prefLabel = current.prefLabel,
            cui = paste(current.cui,
                        sep = ", ",
                        collapse = "; "),
            semanticType = paste(
              current.semanticType,
              sep = ", ",
              collapse = "; "
            ),
            matchType = current.matchType,
            id = current.id,
            ontology = current.ontology
          )
        )
        
      })
    print(length(current.result.match))
    if (length(current.result.match) > 0) {
      current.result.match <-
        do.call(rbind.data.frame, current.result.match)
      match.count <-
        nrow(current.result.match)
      current.result.match$rank <-
        match.count:1
      return(current.result.match)
    }
  })

result.frame <-
  plyr::rbind.fill(result.frame)


# no results at all for some queries?  needs better tidying
setdiff(search.queries, result.frame$order)

###   ###   ###

cuitemp <-
  unique(result.frame[, c("id", "cui")])

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

sem.type.temp <-
  unique(result.frame[, c("id", "semanticType")])

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

write.table(
  sem.type.temp,
  file = "med_standard_FULL_NAME_bioportal_search_semanticTypes.txt",
  sep = "\t",
  col.names = TRUE,
  row.names = FALSE
)


###   ###   ###

result.frame <-
  result.frame[, c("order",
                   "prefLabel",
                   "matchType",
                   "id",
                   "ontology",
                   "rank")]

save(result.frame, file = "ncbo_med_map_search_res.Rdata")

write.table(
  result.frame,
  file = "ncbo_med_map_search_res.txt",
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE,
  sep = "\t"
)


###   ###   ###

# what are the discrepanicies between the words used in PDS vs BioPortoal ontologies

line.count <- length(search.queries)

text_df <-
  data_frame(line = 1:line.count, text = search.queries)


rx.word.count <- text_df %>%
  unnest_tokens(word, text) %>%
  count(word, sort = TRUE)

rx.word.count$isnumeric <-
  !is.na(as.numeric(rx.word.count$word))

line.count <- length(result.frame$prefLabel)

text_df <-
  data_frame(line = 1:line.count,
             text = as.character(result.frame$prefLabel))


match.word.count <- text_df %>%
  unnest_tokens(word, text) %>%
  count(word, sort = TRUE)

match.word.count$isnumeric <-
  !is.na(as.numeric(match.word.count$word))

common.vocab.check <-
  merge(
    x = rx.word.count,
    y = match.word.count,
    by = "word",
    all = TRUE,
    suffixes = c(".order", ".labels")
  )

common.vocab.check$isnumeric.order[is.na(common.vocab.check$isnumeric.order)] <-
  common.vocab.check$isnumeric.labels[is.na(common.vocab.check$isnumeric.order)]

common.vocab.check <-
  common.vocab.check[!common.vocab.check$isnumeric.order,]

common.vocab.check$n.order[is.na(common.vocab.check$n.order)] <-
  0
common.vocab.check$n.labels[is.na(common.vocab.check$n.labels)] <-
  0

# would be nice to find some way to constrain these values (0-1) 
# as opposed to open -ended differences

common.vocab.check$diff <-
  common.vocab.check$n.order - common.vocab.check$n.labels

###   ###   ###

source.popularity <-
  as.data.frame(table(result.frame$rank, result.frame$ontology))
names(source.popularity) <-
  c("rank", "ontology", "count")

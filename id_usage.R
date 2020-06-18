library(rdflib)
library(dbscan)

# last.id <- 2000
last.id <- 100000000
tick.spacing <- 100

turbo.ontology.path <-
  paste0(
    "https://raw.githubusercontent.com/PennTURBO/Turbo-Ontology/master/ontologies/robot_implementation/",
    "turbo_merged.ttl"
  )

turbo.ont <-
  rdflib::rdf_parse(doc = turbo.ontology.path, format = "turtle")

turbo.id.usage.query <- '
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
select
#*
?s ?l ?afterlen ?afterval
where {
    values ?base {
        "http://transformunify.org/ontologies/TURBO_"
    }
    ?s a ?t ;
       rdfs:label ?l .
    filter(strstarts(str(?s), ?base))
    bind(xsd:integer(strafter(str(?s), ?base)) * 1 as ?afterval )
    bind(strlen(strafter(str(?s), ?base)) as ?afterlen)
}
'

Sys.time()
system.time(
  turbo.id.usage.result <-
    rdflib::rdf_query(rdf = turbo.ont, query = turbo.id.usage.query)
)

densest <-
  sort(turbo.id.usage.result$afterval[turbo.id.usage.result$afterval < last.id])

temp <- cbind(densest, 1:length(densest))

plot(temp, pch = 20, axes = FALSE)

# plot(1:10, 1:10, axes = FALSE)
axis(side = 1, at = seq(0, 10000000, tick.spacing))
# axis(side = 2, at = c(1,3,7,10))
box()

# attempt to explicitly identify clusters of ID values
# fake.2.d <-
#   cbind(densest,
#         jitter(densest, amount = 1000))
#
# plot(fake.2.d, pch = 3)
#
# res <- optics(fake.2.d, minPts = 3)
# res
#
# ### get order
# res$order
#
# ### plot produces a reachability plot
# plot(res)
#
# plot(fake.2.d, col = "grey")
# polygon(fake.2.d[res$order,])
#
# res <- extractDBSCAN(res, eps_cl = 1e-10)
# res
#
# plot(res)  ## black is noise
# hullplot(fake.2.d, res)
#

# are recently added term requirement salready in TURBO?

more_specimens <- readr::read_delim(
  "~/loinc_in_obo/more-specimens.tsv",
  "\t",
  escape_double = FALSE,
  col_names = TRUE,
  trim_ws = TRUE,
  skip = 1
)

temp <- as.character(unlist(as.data.frame(more_specimens[, 7:8])))
temp <- sort(temp[!is.na(temp)])

turbo.clasified.terms.q <- '
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
select
distinct
?s ?l
#?s (lcase(str(?l)) as ?label)
where {
    ?s a ?t ;
       rdfs:label ?l filter(isiri(?s)) filter(isiri(?t))
}
'

Sys.time()
system.time(
  turbo.clasified.terms.res <-
    rdflib::rdf_query(rdf = turbo.ont, query = turbo.clasified.terms.q)
)

setdiff(temp, turbo.clasified.terms.res$s)

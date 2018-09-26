add clamp for wes pds
add X for epic... medex done, requires slightly different parsing?
clamp GUI might take a while
do bioportal search + svm

## Run medex vs `FULL_NAME`s from `wes_pds__med_standard.csv`

Only submit rows for which a PDS-assigned `RXNORM` is available

Submit as a single file (with 1551 rows and one column, no header)

running medex in default CLI mode on Mark's laptop
time: ~ 1.5 minutes
Number of medications detected ?

CLAMP and medex provide two levels of specificity for their RxNorm predictions.  Which is more similar with the MDM annotations?


## Merge medex results against the PDS provided RXNORMs and review

```
submitted.strings.filename <-
  "wes_pds__med_standard_names_for_lex_search.txt"

data.path <-
  "C:/Users/Mark Miller/Desktop/medex_offline/"

# known.rxns <- ""

submitted.strings <-
  read_delim(
    paste0(data.path, "input/", submitted.strings.filename),
    "\t",
    col_names = FALSE,
    escape_double = FALSE,
    trim_ws = FALSE
  )

medex.output <-
  read_delim(
    paste0(data.path, "output/", submitted.strings.filename),
    "|",
    col_names = FALSE,
    escape_double = FALSE,
    trim_ws = FALSE
  )

first.split <- strsplit(medex.output$X1, "\t")
first.split <- do.call(rbind.data.frame, first.split)
names(first.split) <- c("line.num", "submission")
first.split$line.num <- as.character(first.split$line.num)
first.split$line.num <- as.numeric(first.split$line.num)
medex.output.tidied <- cbind.data.frame(first.split, medex.output)
medex.output.tidied.minimal <-
  medex.output.tidied[,   c("line.num", "submission", "X11", "X12", "X13", "X14")]

known.name2rxn <-
  read_csv("C:/Users/Mark Miller/Desktop/wes_pds__med_standard.csv")
known.name2rxn.minimal <-
  unique(known.name2rxn[!is.na(known.name2rxn$RXNORM), c("PK_MEDICATION_ID", "FULL_NAME", "RXNORM")])

known.name2rxn.minimal <-
  known.name2rxn.minimal[order(known.name2rxn.minimal$FULL_NAME),]
known.name2rxn.minimal$row.num <- 1:nrow(known.name2rxn.minimal)

merged <- merge(
  x = medex.output.tidied.minimal,
  y = known.name2rxn.minimal,
  by.x = "line.num",
  by.y = "row.num",
  all = TRUE
)
merged$same.string <- merged$submission == merged$FULL_NAME

write.csv(merged, file = "wes_pds__med_standard_medex_having_pds_rxn.csv", row.names = FALSE)

```

### Quick assessment of the 1551 input medications:

```
> merged$X13.v.PDX <- merged$X13 == merged$RXNORM
> table(merged$X13.v.PDX, useNA = 'always')

FALSE  TRUE  <NA> 
 1427   180     6 

> merged$X12.v.PDX <- merged$X12 == merged$RXNORM
> table(merged$X12.v.PDX, useNA = 'always')

FALSE  TRUE  <NA> 
  566  1041     6 
```

## Load medex results into graph

```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
            mydata:cui ?X11 ;
            mydata:medex_rxn_general ?medex_rxn_general ;
            mydata:medex_rxn_specific ?medex_rxn_specific ;
            mydata:parsed_med ?X14 ;
            mydata:PK_MEDICATION_ID ?PK_MEDICATION_ID ;
            mydata:FULL_NAME ?FULL_NAME ;
            mydata:PDS_RXNORM ?PDS_RXNORM .
    }
} WHERE {
    SERVICE <ontorefine:2022560102294> {
        ?row a mydata:Row .
        optional {
            ?row  mydata:line.num ?line_num .
        }
        optional {
            ?row  mydata:submission ?submission .
        }
        optional {
            ?row mydata:X11 ?X11  .
        }
        optional {
            ?row mydata:X12 ?X12  .
        }
        optional {
            ?row mydata:X13 ?X13  .
        }
        optional {
            ?row mydata:X14 ?X14  .
        }
        optional {
            ?row mydata:PK_MEDICATION_ID ?PK_MEDICATION_ID  .
        }
        optional {
            ?row mydata:FULL_NAME ?FULL_NAME  .
        }
        optional {
            ?row  mydata:RXNORM ?RXNORM .
        }                        
        optional {
            ?row mydata:same.string ?same_string  .
        }                        
        optional {
            ?row mydata:X12.v.PDS ?X12_v_PDS  .
        }                        
        optional {
            ?row mydata:X13.v.PDS ?X13_v_PDS  .
        }
        BIND(uuid() AS ?myRowId)
        BIND(uri(concat("http://purl.bioontology.org/ontology/RXNORM/", ?X12)) AS ?medex_rxn_general)
        BIND(uri(concat("http://purl.bioontology.org/ontology/RXNORM/", ?X13)) AS ?medex_rxn_specific)
        BIND(uri(concat("http://purl.bioontology.org/ontology/RXNORM/", ?RXNORM)) AS ?PDS_RXNORM)
    }
}
```

> Added 12904 statements. Update took 1.4s, moments ago. 

## Remove statements in which the object is "NA"

They come from R's processing of empty medex values

```
PREFIX mydata: <http://example.com/resource/>
delete {
    graph mydata:wes_pds_v_medex {
        ?s ?p "NA" .
    }
}
where {
    graph mydata:wes_pds_v_medex {
        ?s ?p "NA" .
    }
}
```

> Removed 542 statements. Update took 0.1s, moments ago. 

## Remove statements in which the object is <http://purl.bioontology.org/ontology/RXNORM/NA>

They come from the real-time URI creation, when the input is an NA from R's processing of empty medex values

```
PREFIX mydata: <http://example.com/resource/>
delete {
    graph mydata:wes_pds_v_medex {
        ?s ?p <http://purl.bioontology.org/ontology/RXNORM/NA> .
    }
}
where {
    graph mydata:wes_pds_v_medex {
        ?s ?p <http://purl.bioontology.org/ontology/RXNORM/NA> .
    }
}
```

> Removed 12 statements. Update took 0.1s, moments ago. 

## Flag cases where medex's specific RXNORM matches the PDS RxNORM exactly

```
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:medex_specific_pds_same_term true
    }
}
where {
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 mydata:medex_rxn_specific ?shared ;
                 mydata:PDS_RXNORM ?shared .
    }
}
```

> Added 180 statements. Update took 0.1s, moments ago. 

## Flag cases where medex's general RXNORM matches the PDS RxNORM exactly

```
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:medex_general_pds_same_term true
    }
}
where {
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 mydata:medex_rxn_general ?shared ;
                 mydata:PDS_RXNORM ?shared .
    }
}
```

> Added 1041 statements. Update took 0.2s, moments ago. 

## Flag cases where medex's general RXNORM term has a direct relationship with the PDS RxNORM term

Some of those relationships may not be strong enough to consider the medex result correct.  See below.

```
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:medex_general_pds_linking_predicate ?p
    }
}
where {
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 mydata:medex_rxn_general ?medex_rxn_general ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?medex_rxn_general ?p ?PDS_RXNORM
    }
}
```

> Added 245 statements. Update took 0.2s, moments ago. 

## Flag cases where medex's specific RXNORM term has a direct relationship with the PDS RxNORM term

```
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:medex_specific_pds_linking_predicate ?p
    }
}
where {
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 mydata:medex_rxn_specific ?medex_rxn_specific ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?medex_rxn_specific ?p ?PDS_RXNORM
    }
}
```

> Added 120 statements. Update took 0.1s, moments ago. 

## Check the relationships.  Some may not be strong enough to consider the medex result correct. 

111 rxnorm:ingredient_of. all low: rxnorm:part_of, rxnorm:ingredients_of, rxnorm:dose_form_of, rxnorm:form_of

```
PREFIX mydata: <http://example.com/resource/>
select 
?p (count(distinct ?myRowId) as ?count)
where
{
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:medex_general_pds_linking_predicate ?p
    }
}
group by ?p
order by desc (count(distinct ?myRowId))
```

> Showing results from 1 to 11 of 11. Query took 0.1s, moments ago. 

| p                     | count            |
|-----------------------|------------------|
| rxnorm:tradename_of  **(looks ok)** | 115^^xsd:integer |
| rxnorm:ingredient_of *(ok as long as PDS term only has one ingredient)* | 70^^xsd:integer  |
| rxnorm:constitutes *(ok as long as PDS term consists of only one "thing")* | 36^^xsd:integer  |
| rxnorm:inverse_isa **(ok, slightly less specific)**   | 8^^xsd:integer   |
| rxnorm:part_of  **(tricky... see "Calcium Carbonate / Vitamin D" `rxnorm:215830`**| 4^^xsd:integer   |
| rxnorm:contains  **(looks ok, inverse is contained_in)** | 3^^xsd:integer   |
| rxnorm:has_ingredient **(save for later)** | 3^^xsd:integer   |
| rxnorm:ingredients_of   **(looks ok)** | 2^^xsd:integer   |
| rxnorm:isa **(looks ok)** | 2^^xsd:integer   |
| rxnorm:dose_form_of  **NO** | 1^^xsd:integer   |
| rxnorm:form_of **(looks ok**)  | 1^^xsd:integer   |


### Example for double checking:

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
?mgl ?lp ?pl ?PDS_RXNORM (count(distinct ?pi) as ?ing_count)
where {
    values ?lp {
        rxnorm:ingredient_of 
    }
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 mydata:medex_rxn_general ?medex_rxn_general ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?medex_rxn_general skos:prefLabel ?mgl ;
                           ?lp ?PDS_RXNORM .
        ?PDS_RXNORM skos:prefLabel ?pl .
        optional {
            ?PDS_RXNORM   rxnorm:has_ingredient ?pi .
        }
    }
}
group by ?mgl ?lp ?pl ?PDS_RXNORM 
order by ?mgl ?pl
```

> Showing results from 1 to 49 of 49. Query took 0.1s, moments ago. 

Results omitted.



## Flag cases where medex's general RXNORM term and the PDS RxNORM term share a parent class

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:medex_general_pds_shared_type ?shared   
    }
}
where {
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 mydata:medex_rxn_general ?medex_rxn_general ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?medex_rxn_general rxnorm:isa ?shared .
        ?PDS_RXNORM  rxnorm:isa ?shared .
    }
}
```

> Added 2687 statements. Update took 0.2s, moments ago. 

### Do vague classes like "oral tablet" rise to the top?  Doesn't look that way.

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select
?lab (count(distinct ?myRowId) as ?count)
where {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:medex_general_pds_shared_type ?shared   
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?shared skos:prefLabel ?lab
    }
}
group by ?lab 
order by desc (count(distinct ?myRowId))
```

> Showing results from 1 to 1,000 of 1,124. Query took 0.4s, moments ago. 



| lab                               | count           |
|-----------------------------------|-----------------|
| levothyroxine Oral Product@en     | 17^^xsd:integer |
| levothyroxine Pill@en             | 17^^xsd:integer |
| Cholecalciferol Oral Product@en   | 15^^xsd:integer |
| Cholecalciferol Pill@en           | 15^^xsd:integer |
| gabapentin Oral Product@en        | 12^^xsd:integer |
| Calcium Carbonate Oral Product@en | 11^^xsd:integer |
| Lisinopril Oral Product@en        | 11^^xsd:integer |
| Lisinopril Oral Tablet@en         | 11^^xsd:integer |
| Lisinopril Pill@en                | 11^^xsd:integer |
| Magnesium Oxide Oral Product@en   | 11^^xsd:integer |


## Flag cases where medex's specific RXNORM term and the PDS RxNORM term share a parent class

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:medex_specific_pds_shared_type ?shared   
    }
}
where {
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 mydata:medex_rxn_specific ?medex_rxn_specific ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?medex_rxn_specific rxnorm:isa ?shared .
        ?PDS_RXNORM  rxnorm:isa ?shared .
    }
}
```

> No statements added or removed. Update took 0.1s, moments ago. 


----

## Make sure we're not looking at obsolete RxNorms

| Properties          | values                     |
|---------------------|----------------------------|
| RxCUI               | 3486                       |
| Concept Name        | Dioctyl Sulfosuccinic Acid |
| Term Type           | IN                         |
| Multiple Ingredient | No                         |
| Branded             | No                         |


| Metadata   | value   |
|------------|---------|
| Status     | Retired |
| Source     | RXNORM  |
| Start Date | May-06  |
| End Date   | Oct-15  |
| Is Current | FALSE   |

Retired 'Dioctyl Sulfosuccinic Acid' is not present in current TURBO graph

What kind of predicates should I expect

Example: `rxnorm:220586` from `<http://data.bioontology.org/ontologies/RXNORM/submissions/15/download>`


| predicate                     | object                                        |
|-------------------------------|-----------------------------------------------|
| rdf:type                      | owl:Class                                     |
| rxnorm:has_precise_ingredient | rxnorm:2672                                   |
| rxnorm:ingredient_of          | rxnorm:1187503                                |
| rxnorm:ingredient_of          | rxnorm:1187505                                |
| rxnorm:ingredient_of          | rxnorm:369248                                 |
| rxnorm:ingredient_of          | rxnorm:993836                                 |
| rxnorm:ingredient_of          | rxnorm:993837                                 |
| rxnorm:ingredient_of          | rxnorm:993891                                 |
| rxnorm:ingredient_of          | rxnorm:993892                                 |
| rxnorm:RXAUI                  | 1184477                                       |
| rxnorm:RXCUI                  | 220586                                        |
| rxnorm:RXN_BN_CARDINALITY     | multi                                         |
| rxnorm:tradename_of           | rxnorm:161                                    |
| rxnorm:tradename_of           | rxnorm:2670                                   |
| skos:notation                 | 220586                                        |
| skos:prefLabel                | Tylenol with Codeine@en                       |


### see also https://www.nlm.nih.gov/research/umls/sourcereleasedocs/current/RXNORM/stats.html

### X should be of type `owl:Class` and should not have a `rxnorm:RXN_OBSOLETED` object.

## compare pds and medex via ingredients?

### what are the predicates used by any RxNorm statement

```
select
?p (count(distinct ?s) as ?count)
where {
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?s ?p ?o .
    }
}
group by ?p 
order by desc(count(distinct ?s))
```

> Showing results from 1 to 55 of 55. Query took 2.4s, moments ago. 

| p                                  | count               |
|------------------------------------|---------------------|
| rdf:type                           | 113662^^xsd:integer |
| skos:notation (rxnorm value) | 113617^^xsd:integer |
| skos:prefLabel                     | 113617^^xsd:integer |
| umls:cui (for UMLS) | 113490^^xsd:integer |
| umls:hasSTY (a semantic type term) | 113490^^xsd:integer |
| umls:tui (a semantic type value) | 113490^^xsd:integer |
| rxnorm:RXAUI (RxNorm atom value... usefulness?) | 113490^^xsd:integer |
| rxnorm:RXCUI (same as skos:notation?) | 113490^^xsd:integer |
| rxnorm:has_ingredient              | 69532^^xsd:integer  |
| rxnorm:has_dose_form               | 45099^^xsd:integer  |
| rxnorm:isa                         | 44346^^xsd:integer  |
| rxnorm:tradename_of                | 43423^^xsd:integer  |
| rxnorm:RXN_AVAILABLE_STRENGTH      | 39536^^xsd:integer  |
| skos:altLabel                      | 34134^^xsd:integer  |
| rxnorm:inverse_isa                 | 34101^^xsd:integer  |
| rxnorm:consists_of                 | 28911^^xsd:integer  |
| rxnorm:has_tradename               | 26161^^xsd:integer  |
| rxnorm:constitutes                 | 24896^^xsd:integer  |
| rxnorm:RXN_HUMAN_DRUG (US or blank?) | 24635^^xsd:integer  |
| rxnorm:RXTERM_FORM (tab, spray, sol...) | 23214^^xsd:integer  |
| rxnorm:NDC                         | 19577^^xsd:integer  |
| rxnorm:has_doseformgroup           | 18843^^xsd:integer  |
| rxnorm:RXN_STRENGTH                | 15457^^xsd:integer  |
| rxnorm:ingredient_of               | 9373^^xsd:integer   |
| rxnorm:RXN_BN_CARDINALITY  (single or multi)| 6053^^xsd:integer   |
| rxnorm:has_precise_ingredient      | 5391^^xsd:integer   |
| rxnorm:RXN_ACTIVATED (date) | 5374^^xsd:integer   |
| rxnorm:RXN_OBSOLETED (date) | 5374^^xsd:integer   |
| rxnorm:has_ingredients             | 4691^^xsd:integer   |
| rxnorm:RXN_QUANTITY                | 4170^^xsd:integer   |
| rxnorm:has_part                    | 3975^^xsd:integer   |
| rxnorm:form_of                     | 2743^^xsd:integer   |
| rxnorm:RXN_IN_EXPRESSED_FLAG       | 2730^^xsd:integer   |
| rxnorm:has_form                    | 1989^^xsd:integer   |
| rxnorm:part_of                     | 1976^^xsd:integer   |
| rxnorm:RXN_VET_DRUG                | 1790^^xsd:integer   |
| rxnorm:ingredients_of              | 1706^^xsd:integer   |
| rxnorm:precise_ingredient_of       | 1059^^xsd:integer   |
| rxnorm:contains                    | 836^^xsd:integer    |
| rxnorm:contained_in                | 634^^xsd:integer    |
| rxnorm:RXN_QUALITATIVE_DISTINCTION | 217^^xsd:integer    |
| rdfs:subClassOf                    | 125^^xsd:integer    |
| rxnorm:dose_form_of                | 117^^xsd:integer    |
| rxnorm:ORIG_CODE                   | 81^^xsd:integer     |
| rxnorm:ORIG_SOURCE                 | 81^^xsd:integer     |
| rxnorm:AMBIGUITY_FLAG              | 65^^xsd:integer     |
| rdfs:comment                       | 45^^xsd:integer     |
| rdfs:label                         | 45^^xsd:integer     |
| rxnorm:doseformgroup_of            | 43^^xsd:integer     |
| rxnorm:quantified_form_of          | 26^^xsd:integer     |
| rxnorm:has_quantified_form         | 21^^xsd:integer     |
| rxnorm:reformulated_to             | 12^^xsd:integer     |
| rxnorm:reformulation_of            | 12^^xsd:integer     |
| owl:imports                        | 1^^xsd:integer      |
| owl:versionInfo                    | 1^^xsd:integer      |

### What are the properties upstream of RxNorm terms used by PDS?

also add downstream and same for medex general and specific

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select
?p (count(distinct ?s) as ?count)
where {
    graph mydata:wes_pds_v_medex {
        ?myRowId mydata:PDS_RXNORM ?pdsrxn  .
    }
    graph  <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?s ?p ?pdsrxn .
    }
}
group by ?p 
order by desc (count(distinct ?s))
```

> Showing results from 1 to 18 of 18. Query took 0.2s, minutes ago. 

| p                             | count             |
|-------------------------------|-------------------|
| rxnorm:has_ingredient         | 4773^^xsd:integer |
| rxnorm:tradename_of           | 2472^^xsd:integer |
| rxnorm:inverse_isa            | 1409^^xsd:integer |
| rxnorm:has_part               | 1116^^xsd:integer |
| rxnorm:constitutes            | 850^^xsd:integer  |
| rxnorm:isa                    | 300^^xsd:integer  |
| rxnorm:form_of                | 162^^xsd:integer  |
| rxnorm:contains               | 113^^xsd:integer  |
| rxnorm:ingredient_of          | 83^^xsd:integer   |
| rxnorm:has_precise_ingredient | 68^^xsd:integer   |
| rxnorm:dose_form_of           | 35^^xsd:integer   |
| rxnorm:has_ingredients        | 29^^xsd:integer   |
| rxnorm:ingredients_of         | 27^^xsd:integer   |
| rxnorm:part_of                | 6^^xsd:integer    |
| rxnorm:quantified_form_of     | 5^^xsd:integer    |
| rxnorm:has_form               | 4^^xsd:integer    |
| rxnorm:consists_of            | 1^^xsd:integer    |
| rxnorm:has_quantified_form    | 1^^xsd:integer    |


### What are the types of anything in RxNorm?

```
PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
?o ?l (count(distinct ?s) as ?count)
where {
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?s umls:hasSTY ?o .
        ?o skos:prefLabel ?l
    }
}
group by ?o ?l
order by desc (count(distinct ?s))
```

> Showing results from 1 to 26 of 26. Query took 0.5s, moments ago. 

prefix bioportal: <http://purl.bioontology.org/ontology/STY/>

| o   | l   | count   |
|---|---|---|
| bioportal:T200 | Clinical Drug@en                           | 88018 |
| bioportal:T121 | Pharmacologic Substance@en                 | 20177 |
| bioportal:T109 | Organic Chemical@en                        | 16604 |
| bioportal:T116 | Amino Acid, Peptide, or Protein@en         | 1512  |
| bioportal:T129 | Immunologic Factor@en                      | 1188  |
| bioportal:T197 | Inorganic Chemical@en                      | 865   |
| bioportal:T203 | Drug Delivery Device@en                    | 836   |
| bioportal:T195 | Antibiotic@en                              | 635   |
| bioportal:T130 | Indicator, Reagent, or Diagnostic Aid@en   | 456   |
| bioportal:T122 | Biomedical or Dental Material@en           | 385   |
| bioportal:T125 | Hormone@en                                 | 369   |
| bioportal:T123 | Biologically Active Substance@en           | 354   |
| bioportal:T196 | Element, Ion, or Isotope@en                | 226   |
| bioportal:T131 | Hazardous or Poisonous Substance@en        | 187   |
| bioportal:T127 | Vitamin@en                                 | 185   |
| bioportal:T114 | Nucleic Acid, Nucleoside, or Nucleotide@en | 155   |
| bioportal:T126 | Enzyme@en                                  | 132   |
| bioportal:T007 | Bacterium@en                               | 112   |
| bioportal:T168 | Food@en                                    | 110   |
| bioportal:T005 | Virus@en                                   | 35    |
| bioportal:T120 | Chemical Viewed Functionally@en            | 22    |
| bioportal:T004 | Fungus@en                                  | 16    |
| bioportal:T204 | Eukaryote@en                               | 14    |
| bioportal:T074 | Medical Device@en                          | 13    |
| bioportal:T025 | Cell@en                                    | 8     |
| bioportal:T104 | Chemical Viewed Structurally@en            | 1     |


## Therefore

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:acceptable_mapping true
    }
}
where {
    values ?lp {
        rxnorm:form_of rxnorm:has_form 
        rxnorm:isa rxnorm:inverse_isa 
        rxnorm:ingredients_of rxnorm:has_ingredients 
        rxnorm:contains rxnorm:contained_in  
        rxnorm:tradename_of rxnorm:has_tradename
    }
    values ?mp {
        mydata:medex_rxn_general 
        mydata:medex_rxn_specific
    }
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 mydata:medex_rxn_general ?medex_rxn_general ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?medex_rxn_general skos:prefLabel ?mgl ;
                           ?lp ?PDS_RXNORM .
        ?PDS_RXNORM skos:prefLabel ?pl .
    }
}
```

and

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:acceptable_mapping true
    }
}
where {
    select ?lp ?backlink ?mp ?myRowId ?medex_rxn ?PDS_RXNORM ?mgl ?pl (count(distinct ?pi) as ?picount)
    where {
        values (?lp ?backlink) {
            (rxnorm:ingredient_of rxnorm:has_ingredient)
            (rxnorm:constitutes rxnorm:consists_of)
        }
        values ?mp {
            mydata:medex_rxn_general 
            mydata:medex_rxn_specific
        }
        graph mydata:wes_pds_v_medex {
            ?myRowId a mydata:wes_pds_v_medex_comparison ;
                     mydata:medex_rxn_general ?medex_rxn ;
                     mydata:PDS_RXNORM ?PDS_RXNORM .
        }
        graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
            ?medex_rxn skos:prefLabel ?mgl ;
                       ?lp ?PDS_RXNORM .
            ?PDS_RXNORM skos:prefLabel ?pl .
            optional {
                ?PDS_RXNORM ?backlink ?pi .
            }
        }
    }
    group by  ?lp ?backlink ?mp ?myRowId ?medex_rxn ?PDS_RXNORM ?mgl ?pl 
    having (count(distinct ?pi) < 2)
}
```

and

```
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:acceptable_mapping true
    }
} where {
    values ?p {
        mydata:medex_specific_pds_same_term mydata:medex_general_pds_same_term
    }
    graph mydata:wes_pds_medex_assessments {
        ?myRowId ?p true
    }
}
```

and

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId mydata:acceptable_mapping true
    }
}
where {
    values ?p {
        mydata:medex_rxn_general mydata:medex_rxn_specific
    }
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 ?p ?medex_rxn ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?medex_rxn rxnorm:isa ?shared .
        ?PDS_RXNORM  rxnorm:isa ?shared .
    }
}
```


----

## Don't bother checking against PDS assigned RxNorms that aren't defined in the current RxNorm graph

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
insert {
    graph mydata:wes_pds_medex_assessments {
        ?myRowId  mydata:pds_rxn_obsolete true
    }
}
where {
    graph mydata:wes_pds_v_medex {
        ?myRowId a mydata:wes_pds_v_medex_comparison ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    minus {
        graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
            ?PDS_RXNORM a owl:Class
        }
    }
}
```

## Dump medication names and PDS RxNorms (from the medex graph we've been working on)

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select 
distinct
?FULL_NAME ?PDS_RXNORM
where {
    graph mydata:wes_pds_v_medex {
        ?s a mydata:wes_pds_v_medex_comparison ;
           mydata:FULL_NAME ?FULL_NAME ;
           mydata:PDS_RXNORM ?PDS_RXNORM
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?PDS_RXNORM a owl:Class
    }
}
```

## Prepare, Submit, and Process in R

```
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

name_rxn_input  <- read_csv("wes_pds_with_valid_rxn.csv")

queries <-
  as.character(name_rxn_input$FULL_NAME)

library(dplyr)
text_df <-
  data_frame(line = 1:nrow(name_rxn_input),
             text = name_rxn_input$FULL_NAME)
library(tidytext)
token.appearances <- text_df %>%
  unnest_tokens(word, text)
token.counts <- table(token.appearances$word)
token.counts <-
  cbind.data.frame(names(token.counts), as.numeric(token.counts))
names(token.counts) <- c("token", "count")

# Acetaminophen 500 MG Oral Tablet - RxNORM (RXNORM)

# fix soem of the UPHS idosyncratic langage to better match terms from preferred ontologies

queries <- cbind.data.frame(queries, tolower(queries))

names(queries) <- c("FULL_NAME", "FULL_NAME.lc")

queries$expanded <-
  stringr::str_replace_all(
    queries$FULL_NAME.lc,
    c(
      "\\baepb\\b" = "aerosol powder",
      "\\baers\\b" = "aerosol",
      "\\balum\\b" = "aluminum",
      "\\bcaps\\b" = "capsule",
      "\\bcorrection\\b" = "",
      "\\bcpdr\\b" = "delayed release capsule",
      "\\bcrea\\b" = "cream",
      "\\bcrys\\b" = "",
      "\\bdosing\\b" = "",
      "\\bdss\\b" = "docusate",
      "\\benem\\b" = "enema",
      "\\ber\\b" = "extended release",
      "\\bex\\b" = "external",
      "\\binjection_\\b" = "injectable solution",
      "\\bivpb\\b" = "injectable solution",
      "\\bliqd\\b" = "liquid",
      "\\bmag\\b" = "magnesium",
      "\\bmonohyd\\b" = "monohydrate",
      "\\boint\\b" = "ointment",
      "\\bor\\b" = "oral",
      "\\bpo\\b" = "oral",
      "\\bpush\\b" = "",
      "\\bsc\\b" = "",
      "\\bsimeth\\b" = "simethicone",
      "\\bsmz\\b" = "sulfamethoxazole",
      "\\bsoln\\b" = "solution",
      "\\bsolr\\b" = "solution",
      "\\bsopn\\b" = "solution",
      "\\bsr\\b" = "extended release",
      "\\bstrp\\b" = "strip",
      "\\bsupp\\b" = "suppository",
      "\\bsusp\\b" = "suspension",
      "\\bsyrp\\b" = "syrup",
      "\\btab\\b" = "tablet",
      "\\btabs\\b" = "tablet",
      "\\btbcr\\b" = "extended release tablet",
      "\\btbdp\\b" = "",
      "\\btbec\\b" = "enteric coated oral tablet",
      "\\btmp\\b" = "trimethoprim",
      "\\bunits\\b" = "unit"
      # "\\bsubl\\b" = "sublingual"
    )
  )

# in could be inhaler
#alum & mag

temp <- queries$expanded

temp <-
  gsub(pattern = "_+",
       replacement = " ",
       x = temp)

temp <-
  gsub(pattern = "^\\W+",
       replacement = "",
       x = temp)

temp <-
  gsub(pattern = "\\W+$",
       replacement = "",
       x = temp)

temp <-
  gsub(pattern = " +",
       replacement = " ",
       x = temp)

queries$expanded <- temp

unique.queries <- sort(unique(queries$expanded))

# search the tidied standard fullnames agaisnt all ontologies in the BioPortal

### long term goals
# check the resutls agaisnt the exisiting RxNORM annotations...
#   may need to tolerate orders that are more specific
# where possible, map anything that isn't already from RxNORM to RxNORM
# then map from RxNORM to realist ontologies like DRON and ChEBI

start.time <- Sys.time()
result.list <- lapply(unique.queries, function(current.order) {
  print(current.order)
  encoded.order <-
    URLencode(current.order, reserved = TRUE)
  # print(encoded.order)
  composed.query <- paste0(
    "https://data.bioontology.org/search?",
    "apikey=9cf735c3-a44a-404f-8b2f-c49d48b2b8b2&",
    "q=",
    encoded.order,
    "&pagesize=30"
  )
  # print(composed.query)
  temp <-
    rawToChar(httr::GET(composed.query)$content)
  temp <- fromJSON(temp)
  return(temp)
})
stop.time <- Sys.time()
names(result.list) <- unique.queries

###   ###   ###

# save(result.list, file = "wes_pds_with_pds_rxn_bioportal.Rdata")
#
# ###   ###   ###
#
# load(file = "coverage90.Rdata")

forward.march <-
  lapply(unique.queries, function(current.query) {
    print(current.query)
    corl <- result.list[[current.query]]
    if ("collection" %in% names(corl) &&
        length(corl[["collection"]]) > 0) {
      corl.coll <- corl[["collection"]]
      t1 <- lapply(corl.coll, function(current.coll) {
        superficial <-
          current.coll[c("prefLabel", "matchType", "@id")]
        if ("links" %in% names(current.coll)) {
          linked.ontolgy <- current.coll[["links"]]$ontology
          
        } else {
          linked.ontolgy <- ""
        }
        names(linked.ontolgy) <- "ontology"
        names(current.query) <- "order"
        
        if ("semanticType" %in% names(current.coll)) {
          semanticType <-
            paste0(current.coll[["semanticType"]], collapse = "; ")
          
        } else {
          semanticType <- ""
        }
        names(semanticType) <- "semanticType"
        combined <-
          c(current.query,
            superficial,
            linked.ontolgy,
            semanticType)
        combined <- combined[!is.na(names(combined))]
        combined <- as.data.frame(combined)
        return(combined)
      })
      t1 <- rbind.fill(t1)
      t1$hit.count <- nrow(t1)
      t1$rank <- 1:nrow(t1)
      return(t1)
    } else {
      return(NULL)
    }
  })
result.frame <- rbind.fill(forward.march)

temp <- which(names(result.frame) == "X.id")
names(result.frame)[temp] <- "id"

sdmeths = c("lv", "lcs", "qgram", "cosine", "jaccard", "jw")

distances <-
  apply(
    X = result.frame,
    MARGIN = 1,
    FUN = function(current.row) {
      print(as.character(current.row['order']))
      pds.string <- tolower(as.character(current.row['order']))
      found.string <-
        tolower(as.character(current.row['prefLabel']))
      sdresults <- lapply(sdmeths, function(current.meth) {
        one.dist <-
          stringdist(a = pds.string, b = found.string, method = current.meth)
        return(current.meth = one.dist)
      })
      
      return(sdresults)
    }
  )

distances <- do.call(rbind.data.frame, distances)
names(distances) <- sdmeths

distances.scaled <- scale(distances)

result.frame <- cbind.data.frame(result.frame, distances.scaled)


sem.type.temp <-
  unique(result.frame[nchar(as.character(result.frame$semanticType)) > 0, c("id", "semanticType")])

sem.type.temp <-
  sem.type.temp[sem.type.temp$semanticType != "NULL" ,]

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
sem.type.temp$placeholder <- 1

sem.type.cross <-
  cast(
    data = sem.type.temp,
    formula = id ~ semanticType,
    fun.aggregate = max,
    value = "placeholder"
  )

sem.type.cross.binary <-
  as.matrix.data.frame(sem.type.cross[, 2:ncol(sem.type.cross)])
sem.type.cross.binary[sem.type.cross.binary != 1] <- 0

sem.type.cross.binary <- as.data.frame(sem.type.cross.binary)
# sem.type.cross.binary[] <- lapply(sem.type.cross.binary[], as.logical )

temp <- sort(colSums(sem.type.cross.binary))
temp <- cbind.data.frame(names(temp), as.numeric(temp))
names(temp) <- c("type", "count")
temp.max <- max(temp$count)
keepers <- temp$type[temp$count > temp.max / 100]
ditchers <- setdiff(temp$type, keepers)
preserved <- sem.type.cross.binary

sem.type.cross.binary <- sem.type.cross.binary[, keepers]

setaside.names <- as.character(keepers)


sem.type.cross <-
  cbind.data.frame(sem.type.cross$id, sem.type.cross.binary)

names(sem.type.cross)[[1]] <- "id"

semterm.cols <- names(sem.type.cross)[2:ncol(sem.type.cross)]


###   ###   ###

add.sem.type <-
  result.frame[, c(
    "prefLabel",
    "matchType",
    "id",
    "ontology",
    "hit.count",
    "rank",
    "order",
    "lv",
    "lcs",
    "qgram",
    "cosine",
    "jaccard",
    "jw"
  )]

add.sem.type <-
  merge(x = add.sem.type,
        y = sem.type.cross,
        by = "id",
        all.x = TRUE)

setaside <- as.matrix(add.sem.type[, as.character(setaside.names)])

add.sem.type <-
  add.sem.type[, setdiff(colnames(add.sem.type), setaside.names)]

setaside[is.na(setaside)] <- 0
setaside <- as.data.frame(setaside)

add.sem.type <-
  cbind.data.frame(add.sem.type, setaside)


rxnorm_bioportal_mappings <-
  read.delim("C:/Users/Mark Miller/Desktop/rxnorm_bioportal_mappings.tsv",
             header = FALSE)

idx <-
  match(as.character(add.sem.type$id),
        as.character(rxnorm_bioportal_mappings$V4))

add.sem.type$indirect <- rxnorm_bioportal_mappings$V1[idx]

add.sem.type$direct[add.sem.type$ontology == "http://data.bioontology.org/ontologies/RXNORM"] <-
  as.character(add.sem.type$id[add.sem.type$ontology == "http://data.bioontology.org/ontologies/RXNORM"])

add.sem.type$rxnifavailalbe <- ""

add.sem.type$rxnifavailalbe[!is.na(add.sem.type$direct)] <-
  as.character(add.sem.type$direct[!is.na(add.sem.type$direct)])

add.sem.type$rxnifavailalbe[!is.na(add.sem.type$indirect)] <-
  as.character(add.sem.type$indirect[!is.na(add.sem.type$indirect)])



add.sem.type <-
  merge(
    x = add.sem.type,
    y = queries,
    by.x = "order",
    by.y = "expanded",
    all.x = TRUE
  )


add.sem.type <-
  merge(x = add.sem.type,
        y = name_rxn_input,
        by = "FULL_NAME",
        all.x = TRUE)

write_csv(add.sem.type, path = "wes_pds_having_rxn_v_bioportal_processed.csv", col_names = TRUE)


# add.sem.type <- add.sem.type[,c("id", "prefLabel", "matchType", "ontology", "hit.count", "rank",
#                   "order", "lv", "lcs", "qgram", "cosine", "jaccard", "jw", "T195",
#                   "T116", "T121", " T109", "T109", " T121", "T200", "indirect",
#                   "direct", "rxnifavailalbe")]

```

## Load Processed Results back into Graph

```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
    graph mydata:wes_pds_v_bioportal {
        ?myRowId a mydata:processed_bioportal_search_res ;
            mydata:FULL_NAME ?FULL_NAME ;
            mydata:order ?order ;
            mydata:id ?id ;
            mydata:prefLabel ?prefLabel ;
            mydata:matchType ?matchType ;
            mydata:ontology ?ontology ;
            mydata:hit.count ?hit_count ;
            mydata:rank ?rank ;
            mydata:lv ?lv ;
            mydata:lcs ?lcs ;
            mydata:qgram ?qgram ;
            mydata:cosine ?cosine ;
            mydata:jaccard ?jaccard ;
            mydata:jw ?jw ;
            mydata:T195 ?T195 ;
            mydata:T116 ?T116 ;
            mydata:T121 ?T121 ;
            mydata:T109 ?T109 ;
            mydata:T1092 ?T1092 ;
            mydata:T1212 ?T1212 ;
            mydata:T200 ?T200 ;
            mydata:indirect ?indirect ;
            mydata:direct ?direct ;
            mydata:rxnifavailalbe ?rxnifavailalbe ;
            mydata:FULL_NAME.lc ?FULL_NAME_lc ;
            mydata:PDS_RXNORM ?PDS_RXNORM .
    }
} WHERE {
    SERVICE <ontorefine:2531897278245> {
        ?row a mydata:Row ;
             mydata:FULL_NAME ?FULL_NAME ;
             mydata:order ?order ;
             mydata:id ?id ;
             mydata:prefLabel ?prefLabel ;
             mydata:matchType ?matchType ;
             mydata:ontology ?ontology ;
             mydata:hit.count ?hit_count ;
             mydata:rank ?rank ;
             mydata:lv ?lv ;
             mydata:lcs ?lcs ;
             mydata:qgram ?qgram ;
             mydata:cosine ?cosine ;
             mydata:jaccard ?jaccard ;
             mydata:jw ?jw ;
             mydata:T195 ?T195 ;
             mydata:T116 ?T116 ;
             mydata:T121 ?T121 ;
             mydata:T109 ?T109 ;
             mydata:T1092 ?T1092 ;
             mydata:T1212 ?T1212 ;
             mydata:T200 ?T200 ;
             mydata:indirect ?indirect ;
             mydata:direct ?direct ;
             mydata:FULL_NAME.lc ?FULL_NAME_lc ;
             mydata:PDS_RXNORM ?PDS_RXNORM .
        optional {
            ?row mydata:rxnifavailalbe ?rxnifavailalbe ;
                 }
        BIND(uuid() AS ?myRowId)
    }
}

```

> Added 1827900 statements. Update took 2m 48s, minutes ago. 

## Remove NA objects from BioPortal results

```
PREFIX mydata: <http://example.com/resource/>
delete {
    graph mydata:wes_pds_v_bioportal {
        ?s ?p "NA" .
    }
}
where {
    graph mydata:wes_pds_v_bioportal {
        ?s ?p "NA" .
    }
}
```

> Removed 78008 statements. Update took 0.8s, moments ago. 

## Did we retain evrything?

For example, were there relationships (other than mydata:rxnifavailalbe) that should have been made optional?

### According to R data frame

```
> print(nrow(add.sem.type))
[1] 68129
```

### According to graph

```
PREFIX mydata: <http://example.com/resource/>
select 
(count(distinct ?myRowId) as ?count)
where {
    graph mydata:wes_pds_v_bioportal {
        ?myRowId a mydata:processed_bioportal_search_res
    }
}
```

> Showing results from 1 to 1 of 1. Query took 0.1s, moments ago. 

count
"68129"^^xsd:integer

## Flag identical RxNorm cases

```
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:wes_pds_bioportal_assessments {
        ?myRowId mydata:bioportal_pds_same_term true
    }
}
where {
    graph mydata:wes_pds_v_bioportal {
        ?myRowId a mydata:processed_bioportal_search_res ;
                 mydata:rxnifavailalbe ?shared ;
                 mydata:PDS_RXNORM ?shared .
    }
}
```

Added 13227 statements. Update took 0.8s, moments ago. 

## Flag cases where the PDS RxNorm and the BioPortal RxNorm share a parent type

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
insert {
    graph mydata:wes_pds_bioportal_assessments {
        ?myRowId mydata:bioportal_pds_shared_type ?shared   
    }
}
where {
    graph mydata:wes_pds_v_bioportal {
        ?myRowId a mydata:processed_bioportal_search_res ;
                 mydata:rxnifavailalbe ?medex_rxn_general ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?medex_rxn_general rxnorm:isa ?shared .
        ?PDS_RXNORM  rxnorm:isa ?shared .
    }
}
```

> Added 67165 statements. Update took 1.7s, moments ago. 

## Spot check

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
?shared ?pl (count(distinct ?myRowId) as ?count)
where
{
    graph mydata:wes_pds_bioportal_assessments {
        ?myRowId mydata:bioportal_pds_shared_type ?shared   
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?shared skos:prefLabel ?pl
    }
}
group by ?shared ?pl 
order by desc (count(distinct ?myRowId))
```

> Showing results from 1 to 1,000 of 1,385. Query took 0.4s, moments ago. 



## Flag binary relationship cases

```
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:wes_pds_bioportal_assessments {
        ?myRowId mydata:bioportal_pds_linking_predicate ?p
    }
}
where {
    graph mydata:wes_pds_v_bioportal {
        ?myRowId a mydata:processed_bioportal_search_res ;
                 mydata:rxnifavailalbe ?medex_rxn_general ;
                 mydata:PDS_RXNORM ?PDS_RXNORM .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?medex_rxn_general ?p ?PDS_RXNORM
    }
}
```

> Added 9821 statements. Update took 2.6s, moments ago. 

## What were the binary relationships?

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
?lp (count(distinct ?myRowId  ) as ?count)
where
{
    graph mydata:wes_pds_bioportal_assessments {
        ?myRowId mydata:bioportal_pds_linking_predicate ?lp
    }
}
group by ?lp 
order by desc (count(distinct ?myRowId))
```

> Showing results from 1 to 17 of 17. Query took 0.1s, moments ago.


| lp                            | count             |
|-------------------------------|-------------------|
| rxnorm:tradename_of           | 3886^^xsd:integer |
| rxnorm:inverse_isa            | 1826^^xsd:integer |
| rxnorm:ingredient_of  (ok as long as PDS term only has one ingredient) | 1787^^xsd:integer |
| rxnorm:constitutes (ok as long as PDS term consists of only one "thing") | 1072^^xsd:integer |
| rxnorm:isa / rxnorm:inverse_isa | 327^^xsd:integer  |
| *rxnorm:has_part*               | 263^^xsd:integer  |
| rxnorm:form_of                | 211^^xsd:integer  |
| rxnorm:has_ingredient   (ok as long as BioPortal term only has one ingredient)  | 118^^xsd:integer  |
| *rxnorm:dose_form_of*           | 114^^xsd:integer  |
| rxnorm:contains / rxnorm:contained_in | 65^^xsd:integer   |
| *rxnorm:has_precise_ingredient* | 64^^xsd:integer   |
| rxnorm:ingredients_of / rxnorm:has_ingredients| 48^^xsd:integer   |
| rxnorm:quantified_form_of / rxnorm:has_quantified_form | 11^^xsd:integer   |
| *rxnorm:part_of*                | 10^^xsd:integer   |
| rxnorm:has_form / rxnorm:form_of | 8^^xsd:integer    |
| rxnorm:has_ingredients / rxnorm:ingredients_of | 8^^xsd:integer    |


## Spot check some selected binary relationships
```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select *
where {
    values ?lp {
        rxnorm:form_of rxnorm:has_form 
        rxnorm:isa rxnorm:inverse_isa 
        rxnorm:ingredients_of rxnorm:has_ingredients 
        rxnorm:contains rxnorm:contained_in  
        rxnorm:tradename_of rxnorm:has_tradename
        rxnorm:quantified_form_of rxnorm:has_quantified_form
    }
    graph mydata:wes_pds_v_bioportal {
        ?myRowId a mydata:processed_bioportal_search_res ;
                 mydata:rxnifavailalbe ?rxnifavailalbe ;
                 mydata:PDS_RXNORM ?PDS_RXNORM ;
                 mydata:FULL_NAME ?FULL_NAME .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?rxnifavailalbe skos:prefLabel ?bpl ;
                        ?lp ?PDS_RXNORM .
        ?PDS_RXNORM skos:prefLabel ?pl .
    }
}
```

> Showing results from 1 to 1,000 of 6,393. Query took 0.5s, today at 16:03. 

## Ingredient / constitutes-consists_of situations require additional attention

Still not directly address combination drugs, althogh those may get covered by RxNorm combination term hits

Spot check some!

Also, should look for inverse of these Ingredient / constitutes-consists_of pairs (from perspective of the ingredieant count for the RxNorm term hit in the BioPortal search

Need to do more work on expansion still

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
 ?FULL_NAME ?bpl ?lp ?PDS_RXNORM  (count(distinct ?pi) as ?ing_count)
where
{
    values ?lp {
        rxnorm:ingredient_of 
    }
    graph mydata:wes_pds_bioportal_assessments {
        ?myRowId mydata:bioportal_pds_linking_predicate ?lp
    }
    graph mydata:wes_pds_v_bioportal {
        ?myRowId a mydata:processed_bioportal_search_res ;
                 mydata:rxnifavailalbe ?rxnifavailalbe ;
                 mydata:PDS_RXNORM ?PDS_RXNORM ;
                 mydata:FULL_NAME ?FULL_NAME
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?rxnifavailalbe skos:prefLabel ?bpl .
        ?PDS_RXNORM skos:prefLabel ?pl .
        optional {
            ?PDS_RXNORM   rxnorm:has_ingredient ?pi .
        }
    }
}
group by  ?FULL_NAME ?bpl ?lp ?pl ?PDS_RXNORM 
order by desc (count(distinct ?pi))
```


```
PREFIX mydata: <http://example.com/resource/>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select *
where {
    select ?FULL_NAME ?bioportal_rxn ?bpl ?lp ?PDS_RXNORM ?pl ?backlink 
    #    ?myRowId  
    (count(distinct ?pi) as ?picount)
    where {
        values (?lp ?backlink) {
            (rxnorm:ingredient_of rxnorm:has_ingredient)
            (rxnorm:constitutes rxnorm:consists_of)
        }
        graph mydata:wes_pds_v_bioportal {
            ?myRowId a mydata:processed_bioportal_search_res ;
                     mydata:rxnifavailalbe ?bioportal_rxn ;
                     mydata:PDS_RXNORM ?PDS_RXNORM ;
                     mydata:FULL_NAME ?FULL_NAME .
        }
        graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
            ?bioportal_rxn skos:prefLabel ?bpl ;
                           ?lp ?PDS_RXNORM .
            ?PDS_RXNORM skos:prefLabel ?pl .
            optional {
                ?PDS_RXNORM ?backlink ?pi .
            }
        }
    }
    group by  ?FULL_NAME ?bioportal_rxn ?bpl ?lp ?PDS_RXNORM ?pl ?backlink     
    #    ?myRowId 
    having (count(distinct ?pi) < 2)
}
```


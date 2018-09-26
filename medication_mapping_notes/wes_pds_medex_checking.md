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
| rxnorm:tradename_of   | 115^^xsd:integer |
| rxnorm:ingredient_of  | 70^^xsd:integer  |
| rxnorm:constitutes    | 36^^xsd:integer  |
| rxnorm:inverse_isa    | 8^^xsd:integer   |
| rxnorm:part_of        | 4^^xsd:integer   |
| rxnorm:contains       | 3^^xsd:integer   |
| rxnorm:has_ingredient | 3^^xsd:integer   |
| rxnorm:ingredients_of | 2^^xsd:integer   |
| rxnorm:isa            | 2^^xsd:integer   |
| rxnorm:dose_form_of   | 1^^xsd:integer   |
| rxnorm:form_of        | 1^^xsd:integer   |


### Maybe `rxnorm:ingredient_of ` isn't strong enough.  `rxnorm:tradename_of` probably is.

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








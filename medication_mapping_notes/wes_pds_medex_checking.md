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

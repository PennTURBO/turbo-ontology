solr match type na -> column V1


# High level medication mapping notes

Load OntoRefine repository with 
- public ontologies/RDF data sets (DRON, RXNORM...)
- UPHS data 
    - Nebo "EPIC medication hierarchy.xlsx" @ 25 MB from September 18th
    - Heather MDM/ODS merge, which contains EPIC, Sunrise and more
- More...
- bioportal mappings from Python query
- 


Do some reshaping

Create Solr collection

SCRIPT STARTS HERE.  SEE DEPENDENCIES above and below.

Create a list of medication names
- query the graph for names (of single-ingredient medications)
- must have valid RXNORM annotation
- lowercase and "expand" the UPHS medication names ("HUP" -> "", PO -> oral) 
   
Solr query
- returned fields -> some of the features
-  score, rank, number of hits


create more features
string dist
Levenshtein "qgram"           "cosine"          "jaccard"         Jaro–Winkler
**UMLS semantic types** of the hit term (non exclusive Boolean matrix)
see https://www.nlm.nih.gov/research/umls/META3_current_semantic_types.html and https://metamap.nlm.nih.gov/Docs/SemanticTypes_2013AA.txt
Source ontology for term (single multilevel nominal column or exclusive Boolean matrix)
Method by which the Solr hit term was linked to RxNorm (same CUI, DRON assertion, etc.)
Type of label hit by Solr (rdfs:label, skos:prefLable, skos:alt:label)
number of characters and words in the query and the hit
number of times the term was in across all of the searches
number of times any term for the source ontology was hit across all of the searches 

      
[22] "V1"              "altLabel"        "label"           "prefLabel"       "score"           "rank"            

insert pairs into graph

insert veracity observations into graph

query veracity back into R

backmerge contains 
- RxNorm pairs (UPHS known & Solr proposed)...  roughly 30 for each unique expanded medication name
- features
- veracity assessments
    - same term
    - siblings of same parent
    - separated by one reasonable semantic link
    - separated by two reasonable semantic links
- other housekeeping columns like the original strings

remove features that are at least 0.9 correlated with other features
remove features with an importance of less than 1% of the most important feature

hold back all rows concerning a faction of the medication orders for coverage calculation
then optionally ":throw out" a fraction of the rows tom improve training time during development
then hold back some rows for validation


Use some ML algorithm (like SVM) to determine what pattern of features predicts each of the veracity types
target can be a single veracity level (identical?  shared parent?) or a concatenation of multiple (all four, or few if one is found to be problematic)

Assess the ROC AUC and or sensitivity and specificity of the model with held-back pairs/rows

really straightforward for binary classifications
a little more complex for multilevel

coverage = number of medications names that resulted in a Solr hit that the ML algorithm deemed to have any level of veracity other than false, false, false etc. / number of medications held back for coverage


 



----



Mark todo

- are there any medications that don't get any Solr hits at all?
- add first-pass removal of medication names that don't have any reasonable Solr match (where to draw cutoff on which dimension?)
- monitor factor importance
- monitor factor independence vs correlation


# Medication Mapping Walk-through

## Server specifications/requirements

### Hardware
ITMAT AWS:  r4.xlarge instance "i-0dcd1566cd5f41b0f" currently on 34.236.171.54 

| instance type | RAM      | vCPUs | SSD Storage | Networking       | hourly price |
|---------------|----------|-------|-------------|------------------|--------------|
| r4.xlarge     | 30.5 GiB | 4     | < 100 GB    | Up to 10 Gigabit | $0.266000    |


See https://www.ec2instances.info

### Software
- Ubuntu 16 LTS
- R version 3.4.4 or later
- More recent but not necessarily latest = R 3.5.0 (April, 2018) From <https://cran.r-project.org/bin/windows/base/old/> 
- RStudio 1.1.456

### R libraries

- library(solrium)
- library(rrdf)
- library(tibble)
- library(magrittr)
- library(tidytext)
- library(stringdist)
- library(reshape)
- library(uuid)
- library(httr)
- library(ggbiplot)
- library(kernlab)
- library(pROC)
- library(caret)
- library(e1071)
- library(data.table)
- library(tidyr)

### GraphDB SE 8.6.0
Repo `epic_mdm_ods_20180918`

Default graph is empty

| Graph                     |                                              | Notes
|-------------------------------------------------------------------------|----------------------------------------------|
| http://example.com/resource/bioportal_mappings.tsv                      |                                              | 
| http://example.com/resource/combo_check                                 |                                              |
| http://example.com/resource/curated_roles                               |                                              |
| http://example.com/resource/epic_meds_with_rxnorm                       |                                              |
| http://example.com/resource/epic_meds_with_rxnorm_valcasts              |                                              |
| http://example.com/resource/epic_nonobsolete_rxn_10pct_vs_solr          |                                              |
| http://example.com/resource/forcedrels                                  |                                              |
| http://example.com/resource/materialized_dbxr                           |                                              |
| http://example.com/resource/mdm_ods_merged_meds.csv                     |                                              |
| http://example.com/resource/mdm_ods_merged_meds_rxncasts                |                                              |
| http://example.com/resource/normalized_supplementary_mappings           |                                              |
| http://example.com/resource/solr_epic_assessments                       |                                              |
| ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi_lite.owl.gz      | download from specified URI                  |
| https://bitbucket.org/uamsdbmi/dron/raw/master/dron-chebi.owl           | download from specified URI                  |
| https://bitbucket.org/uamsdbmi/dron/raw/master/dron-hand.owl            | download from specified URI                  |
| https://bitbucket.org/uamsdbmi/dron/raw/master/dron-ingredient.owl      | download from specified URI                  |
| https://bitbucket.org/uamsdbmi/dron/raw/master/dron-ndc.owl             | download from specified URI                  |
| https://bitbucket.org/uamsdbmi/dron/raw/master/dron-pro.owl             | download from specified URI                  |
| https://bitbucket.org/uamsdbmi/dron/raw/master/dron-rxnorm.owl          | download from specified URI                  |
| https://bitbucket.org/uamsdbmi/dron/raw/master/dron-upper.owl           | download from specified URI                  |
| http://data.bioontology.org/ontologies/RXNORM/submissions/15/download   | download from specified URI                  |
| http://data.bioontology.org/ontologies/MDDB/submissions/15/download     | convert UMLS (matamorphosys) -> MySQL -> RDF |
| http://data.bioontology.org/ontologies/NDDF/submissions/15/download     | convert UMLS (matamorphosys) -> MySQL -> RDF |
| http://data.bioontology.org/ontologies/NDFRT/submissions/15/download    | convert UMLS (matamorphosys) -> MySQL -> RDF |
| http://data.bioontology.org/ontologies/SNOMEDCT/submissions/15/download | convert UMLS (matamorphosys) -> MySQL -> RDF |
| http://data.bioontology.org/ontologies/VANDF/submissions/15/download    | convert UMLS (matamorphosys) -> MySQL -> RDF |
| http://example.com/resource/wes_pds__med_standard.csv                   | fairly default OntoRefine instantiation      |
| http://example.com/resource/wes_pds_enc__med_order.csv                  | fairly default OntoRefine instantiation      |

UMLS conversion and OntoRefine need elaboration


### Solr 7.5.0

./bin/solr create -c umls_chebi_some_dron_distinct

clear core/collection if necessary

curl http://localhost:8983/solr/umls_chebi_some_dron_distinct/update?commit=true -H "Content-Type: text/xml" --data-binary '<delete><query>*:*</query></delete>'

indicate what terms model combination drugs (2 statements for explicitly asserting either true or false... is anything falling through the cracks or in a conflicted state?)


```
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:combo_check {
        ?RXNORM_CODE_URI mydata:combination_likely false
    }
} 
where {
    select ?RXNORM_CODE_URI
    where {
        graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
            ?RXNORM_CODE_URI a owl:Class .
            optional {
                ?RXNORM_CODE_URI rxnorm:has_ingredient ?ing 
            }
            optional {
                ?RXNORM_CODE_URI rxnorm:has_part ?part
            }
            optional {
                ?RXNORM_CODE_URI rxnorm:contains ?component
            }
            optional {
                ?RXNORM_CODE_URI rxnorm:has_ingredients ?ings
            }
            optional {
                ?RXNORM_CODE_URI rxnorm:has_precise_ingredient ?ping
            }
        }
    } 
    group by ?RXNORM_CODE_URI
    having (
        (count(distinct ?ing) < 2 )  && 
        (count(distinct ?part)  < 2 ) && 
        (count(distinct ?component)  < 2 ) &&
        (count(distinct ?ings)  < 1 ) && 
        (count(distinct ?ping)  < 2 ) 
    )
}
```

and

```
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
PREFIX mydata: <http://example.com/resource/>
insert {
    graph mydata:combo_check {
        ?RXNORM_CODE_URI mydata:combination_likely true
    }
} 
where {
    select ?RXNORM_CODE_URI
    where {
        graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
            ?RXNORM_CODE_URI a owl:Class .
            optional {
                ?RXNORM_CODE_URI rxnorm:has_ingredient ?ing 
            }
            optional {
                ?RXNORM_CODE_URI rxnorm:has_part ?part
            }
            optional {
                ?RXNORM_CODE_URI rxnorm:contains ?component
            }
            optional {
                ?RXNORM_CODE_URI rxnorm:has_ingredients ?ings
            }
            optional {
                ?RXNORM_CODE_URI rxnorm:has_precise_ingredient ?ping
            }
        }
    } 
    group by ?RXNORM_CODE_URI
    having (
        (count(distinct ?ing) > 1 )  || 
        (count(distinct ?part)  > 1 )  ||
        (count(distinct ?component)  > 1 )  ||
        (count(distinct ?ings)  > 0 )  ||
        (count(distinct ?ping)  > 1 ) 
    )
}
```

Run a SPARQL query to eventually populate Solr collections (download results first)

```
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    PREFIX owl: <http://www.w3.org/2002/07/owl#>
    PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
    PREFIX j.0: <http://example.com/resource/>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
    select ?ontology ?id ?bpMatchMeth ?matchType (lcase(str(?o)) as ?anyLabel) ?rxn (concat(group_concat(distinct ?directtui), " ", group_concat(distinct ?indirecttui)) as ?gctui)
    ?direct_combo_likely ?indir_combo_likely
    where {
        values ?ontology {
            <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download>
            <https://bitbucket.org/uamsdbmi/dron/raw/master/dron-upper.owl>
            <http://data.bioontology.org/ontologies/NDDF/submissions/15/download>
            <http://data.bioontology.org/ontologies/MDDB/submissions/15/download>
            <http://data.bioontology.org/ontologies/SNOMEDCT/submissions/15/download>
            <http://data.bioontology.org/ontologies/VANDF/submissions/15/download>
            <http://data.bioontology.org/ontologies/NDFRT/submissions/15/download>
            <https://bitbucket.org/uamsdbmi/dron/raw/master/dron-pro.owl>
            <https://bitbucket.org/uamsdbmi/dron/raw/master/dron-ingredient.owl>
            <https://bitbucket.org/uamsdbmi/dron/raw/master/dron-chebi.owl>
            <https://bitbucket.org/uamsdbmi/dron/raw/master/dron-rxnorm.owl>
            <https://bitbucket.org/uamsdbmi/dron/raw/master/dron-hand.owl>
            <ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi_lite.owl.gz>
            # https://bitbucket.org/uamsdbmi/dron/raw/master/dron-ndc.owl
        }
        graph ?ontology {
            values ?matchType {
                rdfs:label skos:prefLabel skos:altLabel 
            }
            ?id a owl:Class ;
                ?matchType ?o .
            optional {
                ?id umls:tui ?directtui
            }
            optional {
                {
                    graph j.0:bioportal_mappings.tsv {
                        ?mapping rdf:type j.0:bioportal_mapping	;
                                 j.0:matchTerm ?id ;
                                 j.0:inputTerm ?rxn ;
                                 j.0:sourceOnt <http://data.bioontology.org/ontologies/RXNORM> ;
                                 j.0:matchMeth ?bpMatchMeth .
                    }
                    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
                        ?rxn a owl:Class .
                    }
                    graph j.0:combo_check {
                        ?rxn j.0:combination_likely ?direct_combo_likely
                    }
                }
                union 
                {
                    graph <http://example.com/resource/materialized_dbxr> {
                        ?id  j.0:materialized_dbxr ?rxn .
                    }
                    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
                        ?rxn a owl:Class .
                    }
                }
                optional {
                    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
                        ?rxn umls:tui ?indirecttui .
                    }
                }
                graph j.0:combo_check {
                    ?rxn j.0:combination_likely ?indir_combo_likely
                }
            }
        }
    }
    group by  ?ontology ?id ?bpMatchMeth ?matchType ?o ?rxn ?direct_combo_likely ?indir_combo_likely
```

- ontology that term comes from
- id (URI of direct term)
- bpMatchMeth: if BioPortal has mapped this term to RxNorm... by what method?
- matchType: what is the predicate that associated the "anyLabel" with the direct term?
- anyLabel
- rxn (if mappable from direct term)
- gctui: space-delimited group concatenation of the UMLS semantic types for the direct term and the RxNorm "equivalent"
- direct_combo_likely:  is there evidence that the direct term models a combination drug?
- indir_combo_likely:  is there evidence that the mapped RxNorm term models a combination drug?


```
ubuntu@ip-172-31-88-118:~$ head /home/rstudio/for_solr_201810081505.csv
ontology,id,bpMatchMeth,matchType,anyLabel,rxn,gctui,direct_combo_likely,indir_combo_likely
http://data.bioontology.org/ontologies/RXNORM/submissions/15/download,http://purl.bioontology.org/ontology/RXNORM/1244607,,http://www.w3.org/2004/02/skos/core#prefLabel,tafluprost,,T109 T121 ,,
http://data.bioontology.org/ontologies/RXNORM/submissions/15/download,http://purl.bioontology.org/ontology/RXNORM/1244611,,http://www.w3.org/2004/02/skos/core#prefLabel,tafluprost 0.015 mg/ml ophthalmic solution,,T200 ,,
http://data.bioontology.org/ontologies/RXNORM/submissions/15/download,http://purl.bioontology.org/ontology/RXNORM/1244612,,http://www.w3.org/2004/02/skos/core#prefLabel,zioptan,,T109 T121 ,,
http://data.bioontology.org/ontologies/RXNORM/submissions/15/download,http://purl.bioontology.org/ontology/RXNORM/1244616,,http://www.w3.org/2004/02/skos/core#prefLabel,tafluprost 0.015 mg/ml ophthalmic solution [zioptan],,T200 ,,
http://data.bioontology.org/ontologies/RXNORM/submissions/15/download,http://purl.bioontology.org/ontology/RXNORM/283809,,http://www.w3.org/2004/02/skos/core#prefLabel,travoprost,,T109 T121 ,,
http://data.bioontology.org/ontologies/RXNORM/submissions/15/download,http://purl.bioontology.org/ontology/RXNORM/284008,,http://www.w3.org/2004/02/skos/core#prefLabel,travoprost 0.04 mg/ml ophthalmic solution,,T200 ,,
http://data.bioontology.org/ontologies/RXNORM/submissions/15/download,http://purl.bioontology.org/ontology/RXNORM/285032,,http://www.w3.org/2004/02/skos/core#prefLabel,travoprost 0.04 mg/ml ophthalmic solution [travatan],,T200 ,,
http://data.bioontology.org/ontologies/RXNORM/submissions/15/download,http://purl.bioontology.org/ontology/RXNORM/284896,,http://www.w3.org/2004/02/skos/core#prefLabel,travatan,,T109 T121 ,,
http://data.bioontology.org/ontologies/RXNORM/submissions/15/download,http://purl.bioontology.org/ontology/RXNORM/29365,,http://www.w3.org/2004/02/skos/core#prefLabel,calcipotriene,,T109 T121 ,,
```

./solr-7.5.0/bin/post -c umls_chebi_some_dron_distinct -params "overwrite=false" for_solr_201810081505.csv

- Last Modified: about a minute ago 
- Num Docs:1562030
- Max Doc:1562030
- Heap Memory Usage:-1
- Deleted Docs:0

Can now make up an imaginary medication and search for it

http://34.236.171.54:8983/solr/umls_chebi_some_dron_distinct/select?q=anyLabel:(acetaminophen%20codeine)

### R script

Get medications from one of the authorities
With non-obsolete RxNorm annotations (whatever RxNorm term is asserted must also be asserted as a class in the RxNorm vocabulary)

From Nebo's~ 24.6 MB `EPIC medication hierarchy.xlsx` via OntoRefine
http://example.com/resource/epic_meds_with_rxnorm
http://example.com/resource/epic_meds_with_rxnorm_valcasts (Converted medication IDs to integers and RxNorm values to URIs)

Merged 
mdm_r_medication_180917.csv and 
with ods_r_medication_source_180917.csv
to get mdm_ods_merged_meds2.csv? or mdm_ods_merged_meds2.csv?   
from Heather (to add ODS source col to MDM details)

ODS columns
**PK_MEDICATION_ID**	**FULL_NAME**	**SOURCE_CODE**	SOURCE_ORIG_ID	FK_3M_NCID_ID

MDM columns
**PK_MEDICATION_ID**	**FULL_NAME**	PHARMACY_CLASS	SIMPLE_GENERIC_NAME	GENERIC_NAME	THERAPEUTIC_CLASS	PHARMACY_SUBCLASS	AMOUNT	FORM	ROUTE_DESCRIPTION	ROUTE_TYPE	CONTROLLED_MED_YN	DEA_CLASS	RECORD_STATE	FK_3M_NCID_ID	**RXNORM**	RXNORM_DEFINITION	MDM_LAST_UPDATE_DATE	MDM_INSERT_UPDATE_FLAG

Merge on PK_MEDICATION_ID (perfect intersection)

CP-1252 encoding!  FULL_NAMEs are not identical (non-ASCII characters in a very small number of rows from X were tidied in Y)

Add notes on how merge was performed

http://example.com/resource/mdm_ods_merged_meds.csv
http://example.com/resource/mdm_ods_merged_meds_rxncasts

Add more notes about OntoRefine & subsequent value casts etc.

### getting suitable medication names and RxNorms from ODS/MDM



records 

| source   | count               |
|----------|---------------------|
| EMTRAC   | 424637^^xsd:integer |
| THERADOC | 87896^^xsd:integer  |
| SCM      | 245922^^xsd:integer |
| EPIC     | 178629^^xsd:integer |

medication name count per source with rxn

| source | count              |
|--------|--------------------|
| SCM    | 31921^^xsd:integer |
| EPIC   | 10123^^xsd:integer |

Comment out undesired sources

```
PREFIX j.0: <http://example.com/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select
?MEDICATION_ID ?MedicationName ?RXNORM_CODE_URI ?source
where
{
    {
        select
        ?MedicationName
        (count(distinct ?pRXNORM_CODE_URI) as ?count)
        where {
            values ?psource {
                "SCM"
                # "EPIC"
            }
            graph j.0:mdm_ods_merged_meds.csv {
                ?s rdf:type j.0:mdm_medication ;
                   j.0:ods.SOURCE_CODE ?psource ;
                   j.0:FULL_NAME ?MedicationName ;
                   j.0:RXNORM ?pRXNORM_CODE_URI .
            }
            graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
                ?pRXNORM_CODE_URI a owl:Class .
            }
        }
        group by
        ?MedicationName
        having (count(distinct ?pRXNORM_CODE_URI) < 2)
    }
    values ?source {
        "SCM"
        # "EPIC"
    }
    graph j.0:mdm_ods_merged_meds.csv {
        ?s rdf:type j.0:mdm_medication ;
           j.0:ods.SOURCE_CODE ?source ;
           j.0:PK_MEDICATION_ID ?MEDICATION_ID ;
           j.0:FULL_NAME ?MedicationName .
    }
    graph <http://example.com/resource/mdm_ods_merged_meds_rxncasts> {
        ?s j.0:RXNORM_CODE_URI ?RXNORM_CODE_URI .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?RXNORM_CODE_URI a owl:Class .
    }
    graph j.0:combo_check {
        ?RXNORM_CODE_URI j.0:combination_likely false .
    }
}
```

These queries check RxNorm and the UPHS authority files themselves for evidence of combination drugs

SCM result
- Query time 11.54 secs
- 30 556 rows (imposed stricter combination drug filters since table above)
- columns: "MEDICATION_ID"   "MedicationName"  "RXNORM_CODE_URI" "source"


MDM/ODS -> EPIC result
- Query time 11.54 secs
- 7 342 rows (imposed stricter combination drug filters since table above)


optionally take a subset of the rows for faster development

make sure all URIs use full notation, not prefixed notation

"expansion" process removes words that never appear in RxNorm, like the names of retails drugstores (CVS), hospital sites (HUP), routes of administration (intrathecal) etc

AND

converts UPHS favored abbreviations PO -> oral

convert to lower case, remove some punctuation and spurious white-space

submit the resulting unique expanded medication names to Solr:  7 342 EPIC source rows from MDM/ODS becomes 6967 unique Solr inputs

Solr can handle ~ 30 queries per second (could improve with sharding and fancier query submission?)

Any medication order full names that didn't hit anything in Solr?

> setdiff(unique.queries, result.frame$order)
[1] "juvederm"

https://www.juvederm.com/

Across ALL of bioportal, only appears in MESH 

Juvederm Ultra - Medical Subject Headings (MESH)
http://purl.bioontology.org/ontology/MESH/C526061

dailymed/SPLs?  no hits @ https://dailymed.nlm.nih.gov/dailymed/search.cfm?labeltype=all&query=juvederm&pagesize=20&page=1

Before submission to Solr, queries were ditched if there was evidence of a combination drug 

Run SOlr search and request 30 hits.  Solr provides an open-ended score and we also add rank (1  = best)

Since triples about combination drugs were added to the graph, and that data was indexed in Solr, we can now remove Solr hits that correspond to a combination drug

Also remove any rows if no RxNorm term is available for a Solr hit (the hit itself wasn't from RxNorm, and BioPortal didn't provide any mapping)

do some tidying to extract just the most significant portion of URIs that are going to be used as feature names

add some features:
Boolean (exclusive) vectors for each of the ways BioPortal links terms from ontologies of other than RxNorm to RxNorm terms  same URI, same CUI, LOOM lexical matching (or NA, which indicates that the mapping actually came from DRON)

Same thing for the type of label that Solr hit (rdfs:label, skos:prefLabel or skos:altLabel)
Similar (but non-exclusive) Boolean vectors for UMLS semantic types (MAM provide reference)

string similarity:  first remove the words "product" and "containing" from the content of the Solr hits (those never appear in UPHS language).  also replace @ signs used as inter-word delimiters with white-space

calculate "lv", "lcs", "qgram", "cosine", "jaccard", "jw" string similarities between each expanded medication name and the slightly tidied Solr hit contents

distances can be scaled (mean = 0, SD = 1), but I'm saving that decision for the SVM training 

look at pair plots of distances (down-sample?) or PCA?

remove any rows with distances > 3 SD?

lv and lcs highly correlated


----

more features:  number of characters and words in both the medication query and the Solr hit

frequency with which each term was returned by Solr as a hit, and frequency of each ontology as a source of hits


----



    library(readr)
    mdm <-
      read_csv(
        "C:/Users/Mark Miller/Desktop/med_authorities/mdm_r_medication_180917.csv",
        locale = locale(encoding = "WINDOWS-1252")
      )
    
    ods <-
      read_csv(
        "C:/Users/Mark Miller/Desktop/med_authorities/ods_r_medication_source_180917.csv",
        locale = locale(encoding = "WINDOWS-1252")
      )
    
    # Mark Miller@DESKTOP-LA54B7U MINGW64 ~
    #   $ wc -l Desktop/med_authorities/mdm_r_medication_180917.csv
    # 938744 Desktop/med_authorities/mdm_r_medication_180917.csv
    #
    # Mark Miller@DESKTOP-LA54B7U MINGW64 ~
    #   $ wc -l Desktop/med_authorities/ods_r_medication_source_180917.csv
    # 940309 Desktop/med_authorities/ods_r_medication_source_180917.csv
    
    
    # > print(nrow(mdm_r_medication_180917))
    # [1] 937084
    
    # > print(nrow(mdm))
    # [1] 937084
    # > print(nrow(ods))
    # [1] 937084
    
    
    mdm_ods_keymerge <-
      merge(
        x = mdm,
        y = ods,
        by.x = "PK_MEDICATION_ID",
        by.y = "PK_MEDICATION_ID",
        all = TRUE,
        suffixes = c(".mdm", ".ods")
      )
    
    mdm_ods_keymerge$identical.name <-
      mdm_ods_keymerge$FULL_NAME.mdm == mdm_ods_keymerge$FULL_NAME.ods
    
    table(mdm_ods_keymerge$identical.name)
    
    write.csv(mdm_ods_keymerge, file = "mdm_ods_keymerge.csv", row.names =  FALSE)

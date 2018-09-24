## Best Case in Brief: Antipsychotics 

CHEBI:35476 vs EPIC PharmacyClass == Antipsychotics

Using BioPortal mappings to get from a RxNorm  ingredient to a ChEBI ingredient.  (MNapping requested via BioPortal's Mapping API and then saved as a static file.)

```
> print(for.caret)
       
         FALSE   TRUE
  FALSE 259112    545
  TRUE     337   1701
> sensitivity(for.caret)
[1] 0.9987011
> specificity(for.caret)
[1] 0.7573464
```

Why is specificity low?  ChEBI (legitimately) asserts several phenothiazine-class active ingredients to have both an antipsychotic and antiemetic role.  Gotcha!  

| act.ing          | EPIC.count |
|------------------|------------|
| chlorpromazine   | 78         |
| olanzapine       | 38         |
| prochlorperazine | 33         |
| perphenazine     | 27         |
| haloperidol      | 24         |
| trifluoperazine  | 12         |
| promazine        | 10         |
| droperidol       | 5          |
| thiethylperazine | 4          |
| triflupromazine  | 4          |


[Even when the FDA has approved labeling a drug as both an antiemetic and antipsychotic](https://www.accessdata.fda.gov/drugsatfda_docs/label/2010/089903s018lbl.pdf), EPIC never seems to classify products containing that drug as an anti-emetic.


## Analgesics

CHEBI:35480 vs any classifications in `PharmacyClass`, `PharmacySubClass` or `TherapyClass` that contain the substring 'analgesic'

```
> print(sort(allowed))
 [1] "analgesic combinations"                      "analgesics-narcotic"                        
 [3] "analgesics-nonnarcotic"                      "analgesics-peptide channel blockers"        
 [5] "analgesics - anti-inflammatory combinations" "analgesics - topical"                       
 [7] "analgesics & anesthetics"                    "analgesics other"                           
 [9] "otic analgesics"                             "urinary analgesics"                  
```

### Include curated term mappings and curated role assertions

SPARQL query + results download takes ~ 30 seconds

Analysis, including load and parse of EPIC Med H file takes 

epic_to_analgesic_roles_curated_mappings_and_roles_assertions.csv

```
> for.caret <-
+   table(merged$epic.analgesic.flag, merged$turbo.analgesic.flag)
> print(for.caret)
       
         FALSE   TRUE
  FALSE 209765  33500
  TRUE    3531  23454
> sensitivity(for.caret)
[1] 0.9834455
> specificity(for.caret)
[1] 0.411806
```

### No curated triples

```
> print(for.caret)
       
         FALSE   TRUE
  FALSE 228724  13622
  TRUE   10858  12139
> sensitivity(for.caret)
[1] 0.9546794
> specificity(for.caret)
[1] 0.4712162
```


----

### What are the curated mappings?

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select
?rxn ?rl ?match ?cl
where {
    graph mydata:normalized_supplementary_mappings {
        ?s rdf:type mydata:Row ;
           mydata:rxnormInput ?rxn ;
           mydata:matchTerm ?match .
    }
    graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
        ?rxn skos:prefLabel ?rl
    }
    graph <ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi_lite.owl.gz> {
        ?match rdfs:label ?cl
    }
}
```

> Showing results from 1 to 3 of 3. Query took 0.1s, moments ago. 

| rxn         | rl               | match           | cl                   |
|-------------|------------------|-----------------|----------------------|
| rxnorm:1191 | Aspirin@en       | obo:CHEBI_15365 | acetylsalicylic acid |
| rxnorm:161  | Acetaminophen@en | obo:CHEBI_46195 | paracetamol          |
| rxnorm:6750 | Menthol@en       | obo:CHEBI_76310 | (+-)-menthol         |

Without these mappings, (non-combination) aspirin and Tylenol tablets are not considered analgesics, which lowers the sensitivity.

Ironically, it also raises the specificity because a lot of cold remedies contain those ingredients, and the EPIC medication hierarchy doesn't consider those combination products to be analgesics.

So one has to decide what's more important:  matching the questionable EPIC medication hierarchy, or discovering false negatives (which will require the curated triples, or using soem other mapping technique, like DRON)


### What are the curated role assertions?

```
PREFIX mydata: <http://example.com/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
select ?s ?cl where {
    graph mydata:curated_roles {
        ?s rdfs:subClassOf ?restr .
        ?restr a owl:Restriction ;
               owl:onProperty obo:RO_0000087 ;
               owl:someValuesFrom obo:CHEBI_35482
    }
    graph <ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi_lite.owl.gz> {
        ?s rdfs:label ?cl
    }
}
```

> Showing results from 1 to 9 of 9. Query took 0.1s, moments ago. 

| s                | cl                        |
|------------------|---------------------------|
| obo:CHEBI_76310  | (+-)-menthol              |
| obo:CHEBI_6640   | Magnesium salicylate      |
| obo:CHEBI_6754   | Meperidine                |
| obo:CHEBI_7865   | Oxymorphone               |
| obo:CHEBI_7866   | Oxymorphone hydrochloride |
| obo:CHEBI_7982   | pentazocine               |
| obo:CHEBI_9182   | Sodium thiosalicylate     |
| obo:CHEBI_135935 | tapentadol                |
| obo:CHEBI_135912 | ziconotide                |

Including those slightly improves sensitivity

----



## Antiemetics 
CHEBI:50919 vs EPIC PharmacyClass == Antiemetics

```
> print(for.caret)
       
         FALSE   TRUE
  FALSE 247448  19217
  TRUE     565    766
> sensitivity(for.caret)
[1] 0.9977219
> specificity(for.caret)
[1] 0.03833258
```


Analgesic DONE 


## Antiarrhythmics
CHEBI:38070 vs EPIC PharmacyClass == Antiarrhythmic

```
> print(for.caret)
       
         FALSE   TRUE
  FALSE 252082  12495
  TRUE     105    968
> sensitivity(for.caret)
[1] 0.9995836
> specificity(for.caret)
[1] 0.07190077
```


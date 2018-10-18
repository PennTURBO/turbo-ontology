

```
select 
?p (count(distinct ?s) as ?count)
where {
    graph <https://bioportal.bioontology.org/ontologies/NDFRT> {
        ?s ?p ?o .
    }
}
group by ?p 
order by desc (count(distinct ?s))
```

> Showing results from 1 to 65 of 65. Query took 1.5s, minutes ago. 


| row |  p  | count |
|----|------------------------------------------------|--------------------|
| 1  | rdf:type                                       | 36120^^xsd:integer |
| 2  | skos:notation                                  | 36066^^xsd:integer |
| 3  | skos:prefLabel                                 | 36066^^xsd:integer |
| 4  | rdfs:subClassOf                                | 35988^^xsd:integer |
| 5  | umls:cui                                       | 35939^^xsd:integer |
| 6  | umls:hasSTY                                    | 35939^^xsd:integer |
| 7  | umls:tui                                       | 35939^^xsd:integer |
| 8  | ndfrt:NDFRT_KIND                               | 35938^^xsd:integer |
| 9  | ndfrt:NUI                                      | 35938^^xsd:integer |
| 10 | skos:altLabel                                  | 28350^^xsd:integer |
| 11 | ndfrt:LEVEL                                    | 17187^^xsd:integer |
| 12 | ndfrt:VANDF_RECORD                             | 17187^^xsd:integer |
| 13 | ndfrt:VUID                                     | 17187^^xsd:integer |
| 14 | ndfrt:MESH_DUI                                 | 15306^^xsd:integer |
| 15 | ndfrt:MESH_NAME                                | 15306^^xsd:integer |
| 16 | ndfrt:MESH_UI                                  | 15243^^xsd:integer |
| 17 | ndfrt:MESH_DEFINITION                          | 13653^^xsd:integer |
| 18 | ndfrt:has_ingredient                           | 11384^^xsd:integer |
| 19 | ndfrt:DCSA                                     | 9144^^xsd:integer  |
| 20 | ndfrt:NF_NAME                                  | 9144^^xsd:integer  |
| 21 | ndfrt:has_product_component                    | 8773^^xsd:integer  |
| 22 | ndfrt:has_mechanism_of_action                  | 8165^^xsd:integer  |
| 23 | ndfrt:has_physiologic_effect                   | 7865^^xsd:integer  |
| 24 | ndfrt:may_treat                                | 7688^^xsd:integer  |
| 25 | ndfrt:contraindicated_with_disease             | 7512^^xsd:integer  |
| 26 | ndfrt:has_dose_form                            | 6933^^xsd:integer  |
| 27 | ndfrt:STRENGTH                                 | 5975^^xsd:integer  |
| 28 | ndfrt:NDF_UNITS                                | 5974^^xsd:integer  |
| 29 | ndfrt:FDA_UNII_CODE                            | 4653^^xsd:integer  |
| 30 | ndfrt:SNOMED_CID                               | 3839^^xsd:integer  |
| 31 | ndfrt:product_component_of                     | 3029^^xsd:integer  |
| 32 | ndfrt:ingredient_of                            | 2644^^xsd:integer  |
| 33 | ndfrt:may_prevent                              | 2632^^xsd:integer  |
| 34 | ndfrt:may_be_treated_by                        | 1003^^xsd:integer  |
| 35 | ndfrt:has_contraindicating_mechanism_of_action | 516^^xsd:integer   |
| 36 | ndfrt:has_contraindicating_class               | 512^^xsd:integer   |
| 37 | ndfrt:VAC                                      | 486^^xsd:integer   |
| 38 | ndfrt:physiologic_effect_of                    | 475^^xsd:integer   |
| 39 | ndfrt:may_diagnose                             | 460^^xsd:integer   |
| 40 | ndfrt:has_contraindicated_drug                 | 449^^xsd:integer   |
| 41 | ndfrt:has_contraindicating_physiologic_effect  | 376^^xsd:integer   |
| 42 | ndfrt:SNOMED_PARENT                            | 363^^xsd:integer   |
| 43 | ndfrt:induces                                  | 331^^xsd:integer   |
| 44 | ndfrt:has_pharmacokinetics                     | 259^^xsd:integer   |
| 45 | ndfrt:site_of_metabolism                       | 259^^xsd:integer   |
| 46 | ndfrt:mechanism_of_action_of                   | 255^^xsd:integer   |
| 47 | ndfrt:may_be_prevented_by                      | 217^^xsd:integer   |
| 48 | ndfrt:contraindicating_class_of                | 129^^xsd:integer   |
| 49 | ndfrt:dose_form_of                             | 104^^xsd:integer   |
| 50 | ndfrt:may_be_diagnosed_by                      | 85^^xsd:integer    |
| 51 | rdfs:comment                                   | 54^^xsd:integer    |
| 52 | rdfs:label                                     | 54^^xsd:integer    |
| 53 | ndfrt:induced_by                               | 51^^xsd:integer    |
| 54 | ndfrt:has_active_metabolites                   | 35^^xsd:integer    |
| 55 | skos:definition                                | 31^^xsd:integer    |
| 56 | ndfrt:contraindicating_physiologic_effect_of   | 29^^xsd:integer    |
| 57 | ndfrt:effect_may_be_inhibited_by               | 13^^xsd:integer    |
| 58 | ndfrt:contraindicating_mechanism_of_action_of  | 11^^xsd:integer    |
| 59 | ndfrt:pharmacokinetics_of                      | 7^^xsd:integer     |
| 60 | ndfrt:SNOMED_CHILD                             | 6^^xsd:integer     |
| 61 | ndfrt:active_metabolites_of                    | 4^^xsd:integer     |
| 62 | ndfrt:metabolic_site_of                        | 2^^xsd:integer     |
| 63 | ndfrt:may_inhibit_effect_of                    | 1^^xsd:integer     |
| 64 | owl:imports                                    | 1^^xsd:integer     |
| 65 | owl:versionInfo                                | 1^^xsd:integer     |

```
PREFIX mydata: <http://example.com/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
insert {
    graph mydata:RxnIfAvailable {
        ?searchRes mydata:RxnIfAvailable ?RxnIfAvailable .
                ?searchRes mydata:RxnAvailable ?rnxAvailable .
    }
}
where {
    graph mydata:med_standard_FULL_NAME_bioportal_search {
        ?searchRes rdf:type mydata:Row ;
                   mydata:ontology ?srOnt ;
                   mydata:id ?srTermId
    }
    optional {
        graph mydata:rxnorm_bioportal_mappings {
            ?RxnMapping a mydata:Row ;
                        mydata:matchTerm ?srTermId ;
                        mydata:rxnormInput ?RxnMatchRxnTerm .
        }
    }
    bind(if(bound(?RxnMatchRxnTerm), ?RxnMatchRxnTerm, ?srTermId) as ?RxnIfAvailable)
    bind(((?srOnt = <http://data.bioontology.org/ontologies/RXNORM>) || (bound(?RxnMatchRxnTerm))) as ?rnxAvailable )
}

```

> Added 71985 statements. Update took 1.9s, moments ago.
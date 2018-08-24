```
PREFIX mydata: <http://example.com/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
insert {
    graph <http://www.itmat.upenn.edu/biobank/knownToMatchedSharedType> {
        ?searchRes <http://www.itmat.upenn.edu/biobank/knownToMatchedSharedType> ?parent .
    }
}
where {
    graph mydata:wes_pds__med_standard.csv {
        ?standard a mydata:medStandard ;
                  mydata:PK_MEDICATION_ID ?fkmi ;
                  mydata:RXNORM ?rxnval .
    }
    graph mydata:med_standard_FULL_NAME_query_expansion {
        ?extension rdf:type mydata:Row ;
                   mydata:PK_MEDICATION_ID ?fkmi ;
                   mydata:expanded.query ?expanded .
    }
    graph mydata:med_standard_FULL_NAME_bioportal_search {
        ?searchRes rdf:type mydata:Row ;
                   mydata:order ?expanded ;
                   mydata:id ?srTermId .
    } 
    graph mydata:RxnIfAvailable {
        ?searchRes mydata:RxnAvailable true .
        ?searchRes mydata:RxnIfAvailable ?RxnIfAvailable .
    }
    bind(uri(concat("http://purl.bioontology.org/ontology/RXNORM/", ?rxnval)) as ?pdsRxnTerm)
    filter( ?pdsRxnTerm != ?RxnIfAvailable)
    graph <https://bioportal.bioontology.org/ontologies/RXNORM> {
        ?pdsRxnTerm skos:prefLabel ?knownlab ;
                    <http://purl.bioontology.org/ontology/RXNORM/isa> ?parent .
        ?RxnIfAvailable  skos:prefLabel ?foundlab ;
                         <http://purl.bioontology.org/ontology/RXNORM/isa> ?parent .
        #        ?parent  skos:prefLabel ?parentlab .
    }
}
```

> Added 5171 statements. Update took 0.5s, moments ago.
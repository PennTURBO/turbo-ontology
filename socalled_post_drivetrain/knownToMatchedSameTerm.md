```
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph <http://www.itmat.upenn.edu/biobank/knownToMatchedSameTerm> {
        ?sr <http://www.itmat.upenn.edu/biobank/knownToMatchedSameTerm> ?SameRxnTermBool
    }
}
where {
    graph  <http://example.com/resource/med_standard_FULL_NAME_bioportal_search> {
        ?sr a <http://example.com/resource/Row> ;
            <http://example.com/resource/order> ?expandedOrder ;
            <http://example.com/resource/id> ?srMatchingTerm ;
            <http://example.com/resource/ontology> ?srMatchSourceOnt .
    }
    graph <http://example.com/resource/med_standard_FULL_NAME_query_expansion> {
        ?exp a <http://example.com/resource/Row> ;
             <http://example.com/resource/expanded.query> ?expandedOrder ;
             <http://example.com/resource/PK_MEDICATION_ID> ?pkMedId .
    }
    graph <http://example.com/resource/wes_pds__med_standard.csv> {
        ?standard a <http://example.com/resource/medStandard> ;
                  <http://example.com/resource/PK_MEDICATION_ID> ?pkMedId ;
                  <http://example.com/resource/RXNORM> ?standRxnVal .
        bind(uri(concat("http://purl.bioontology.org/ontology/RXNORM/", ?standRxnVal)) as ?standRxnTerm)
    }
    graph <http://example.com/resource/RxnIfAvailable> {
        ?sr <http://example.com/resource/RxnIfAvailable> ?matchRxnTerm .
    }
    bind(( ?standRxnTerm = ?matchRxnTerm ) as ?SameRxnTermBool)
}
```

> Added 13371 statements. Update took 0.4s, moments ago.
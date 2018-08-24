```
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
select 
?pkMedId ?fullName ?expandedOrder ?sr ?srRank ?srMatchingTerm	?srPrefLab	?stringDist	?srMatchType ?srMatchSourceOnt ?standRxnTerm ?matchRxnTerm	?SameRxnTermBool	?knownToMatchedRxnPred ?predlab	?knownToMatchedSharedType ?parentlab
where {
    graph  <http://example.com/resource/med_standard_FULL_NAME_bioportal_search> {
        ?sr a <http://example.com/resource/Row> ;
            <http://example.com/resource/order> ?expandedOrder ;
            <http://example.com/resource/rank> ?srRank ;
            <http://example.com/resource/prefLabel> ?srPrefLab ;
            <http://example.com/resource/id> ?srMatchingTerm ;
            <http://example.com/resource/matchType> ?srMatchType ;
            <http://example.com/resource/ontology> ?srMatchSourceOnt ;
            <http://example.com/resource/stringdist> ?stringDist .
    }
    graph <http://example.com/resource/med_standard_FULL_NAME_query_expansion> {
        ?exp a <http://example.com/resource/Row> ;
             <http://example.com/resource/expanded.query> ?expandedOrder ;
             <http://example.com/resource/PK_MEDICATION_ID> ?pkMedId .
    }
    graph <http://example.com/resource/wes_pds__med_standard.csv> {
        ?standard a <http://example.com/resource/medStandard> ;
                  <http://example.com/resource/PK_MEDICATION_ID> ?pkMedId ;
                  <http://example.com/resource/FULL_NAME> ?fullName ;
                  <http://example.com/resource/RXNORM> ?standRxnVal .
        bind(uri(concat("http://purl.bioontology.org/ontology/RXNORM/", ?standRxnVal)) as ?standRxnTerm)
    }
    graph <http://example.com/resource/RxnIfAvailable> {
        ?sr <http://example.com/resource/RxnAvailable> true ;
            <http://example.com/resource/RxnIfAvailable> ?matchRxnTerm .
    }
    optional {
        graph <http://www.itmat.upenn.edu/biobank/knownToMatchedSameTerm> {
            ?sr <http://www.itmat.upenn.edu/biobank/knownToMatchedSameTerm> ?SameRxnTermBool
        }
    }
    optional {
        graph <http://www.itmat.upenn.edu/biobank/knownToMatchedRxnLinkingPred> {
            ?sr <http://www.itmat.upenn.edu/biobank/knownToMatchedRxnLinkingPred> ?knownToMatchedRxnPred
        }
    }
    optional {
        graph <http://www.itmat.upenn.edu/biobank/knownToMatchedSharedType> {
            ?sr <http://www.itmat.upenn.edu/biobank/knownToMatchedSharedType> ?knownToMatchedSharedType
        }
        graph <https://bioportal.bioontology.org/ontologies/RXNORM> {
            ?knownToMatchedSharedType  skos:prefLabel ?parentlab .
        }
    }
}
limit 300
```

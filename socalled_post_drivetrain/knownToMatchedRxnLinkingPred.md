*this works but could be trimmed down a lot*

	PREFIX mydata: <http://example.com/resource/>
	PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
	PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
	insert {
		graph <http://www.itmat.upenn.edu/biobank/knownToMatchedRxnLinkingPred> {
			?searchRes <http://www.itmat.upenn.edu/biobank/knownToMatchedRxnLinkingPred> ?p
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
		optional {
			graph mydata:med_standard_FULL_NAME_bioportal_search {
				?searchRes rdf:type mydata:Row ;
						   mydata:order ?expanded ;
						   mydata:rank ?srRank ;
						   mydata:stringdist ?stringdist ;
						   mydata:matchType ?srMatchType ;
						   mydata:ontology ?srOnt ;
						   mydata:id ?srTermId .
			} 
			graph mydata:RxnIfAvailable {
				optional 
				{
					?searchRes mydata:RxnAvailable ?rnxAvailable .
					?searchRes mydata:RxnIfAvailable ?RxnIfAvailable .
					bind(strafter(str(?RxnIfAvailable), "http://purl.bioontology.org/ontology/RXNORM/") as ?matchedRxnVal)
				}
			}
			optional {
				graph mydata:rxnorm_bioportal_mappings {
					?RxnMapping a mydata:Row ;
								mydata:matchMeth ?matchMeth ;
								mydata:matchOnt ?RxnMatchOnt ;
								mydata:matchTerm ?srTermId ;
								mydata:rxnormInput ?RxnMatchRxnTerm .
				}
			}
		}
		bind(uri(concat("http://purl.bioontology.org/ontology/RXNORM/", ?rxnval)) as ?pdsRxnTerm)
		filter(strlen(strafter(str(?RxnIfAvailable), "http://purl.bioontology.org/ontology/RXNORM/")) > 0)
		filter( ?rxnval != ?matchedRxnVal)
		optional {
			?pdsRxnTerm ?p ?RxnIfAvailable 
		}
	}

> Added 7219 statements. Update took 10s, moments ago.

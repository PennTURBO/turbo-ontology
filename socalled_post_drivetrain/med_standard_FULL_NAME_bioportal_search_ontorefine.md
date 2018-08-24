```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
    graph mydata:med_standard_FULL_NAME_bioportal_search
    {
        ?myRowId a mydata:Row ;
            mydata:order ?order ;
            mydata:rank ?rank ;
            mydata:prefLabel ?prefLabel ;
            mydata:id ?id ;
            mydata:matchType ?matchType ;
            mydata:ontology ?ontology ;
            mydata:stringdist ?stringdist .
    }
}
WHERE {
    SERVICE <ontorefine:1832133358096> {
        ?row a mydata:Row ;
             mydata:order ?order ;
             mydata:rank ?rank ;
             mydata:prefLabel ?prefLabel ;
             mydata:id ?id ;
             mydata:matchType ?matchType ;
             mydata:ontology ?ontology ;
             mydata:stringdist ?stringdist .
        BIND(uuid() AS ?myRowId)
    }
}
```

> Added 284024 statements. Update took 14s, today at 13:04.

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

> Added 284 024 statements. Update took 14s, today at 13:04.

----

## search results from the top ~ 700 full_names that account for 90% of the orders

#### The best match for each search is now rank #1

```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
#construct
insert {
    graph mydata:med_standard_FULL_NAME_bioportal_search
    {
        ?myRowId a mydata:Row ;
            mydata:order ?order ;
            mydata:rank ?rank ;
            mydata:hit.count ?hit_count ;
            mydata:prefLabel ?prefLabel ;
            mydata:id ?id ;
            mydata:matchType ?matchType ;
            mydata:ontology ?ontology ;
            mydata:stringdist ?stringdist .
    }
}
WHERE {
    SERVICE <ontorefine:2179102789049> {
        ?row a mydata:Row ;
             mydata:order ?order ;
             mydata:rank ?rank ;
             mydata:hit.count ?hit_count ;
             mydata:prefLabel ?prefLabel ;
             mydata:id ?id ;
             mydata:matchType ?matchType ;
             mydata:ontology ?ontology ;
             mydata:stringdist ?stringdist .
        BIND(uuid() AS ?myRowId)
    }
}
```

> Added 63 720 statements. Update took 3.8s, moments ago.

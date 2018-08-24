```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
    graph mydata:med_standard_FULL_NAME_bioportal_search_semanticTypes
    {
        ?myRowId a mydata:Row ;
            mydata:id ?id ;
            <http://www.w3.org/2004/02/skos/core#notation> ?semanticType .
    }
} WHERE {
    SERVICE <ontorefine:1685864579995> {
        ?row a mydata:Row ;
             mydata:id ?id ;
             mydata:semanticType ?semanticType .
        BIND(uuid() AS ?myRowId)
    }
}
```

> Added 64953 statements. Update took 1.7s, moments ago.

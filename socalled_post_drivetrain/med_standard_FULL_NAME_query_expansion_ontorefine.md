```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
    graph mydata:med_standard_FULL_NAME_query_expansion
    {
        ?myRowId a mydata:Row ;
            mydata:PK_MEDICATION_ID ?PK_MEDICATION_ID ;
            mydata:FULL_NAME ?FULL_NAME ;
            mydata:expanded.query ?expanded_query .
    }
} WHERE {
    SERVICE <ontorefine:1540397847941> {
        ?row a mydata:Row ;
             mydata:PK_MEDICATION_ID ?PK_MEDICATION_ID ;
             mydata:FULL_NAME ?FULL_NAME ;
             mydata:expanded.query ?expanded_query .
        BIND(uuid() AS ?myRowId)
    }
}

```

> Added 16416 statements. Update took 0.9s, moments ago.

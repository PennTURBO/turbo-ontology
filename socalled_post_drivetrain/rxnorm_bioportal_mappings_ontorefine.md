```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
    graph mydata:rxnorm_bioportal_mappings
    {
        ?myRowId a mydata:Row ;
            mydata:rxnormInput ?Column_1 ;
            mydata:matchMeth ?Column_2 ;
            mydata:matchOnt ?Column_3 ;
            mydata:matchTerm ?Column_4 .
    }
} WHERE {
    SERVICE <ontorefine:1907364078687> {
        ?row a mydata:Row ;
             mydata:Column_1 ?Column_1 ;
             mydata:Column_2 ?Column_2 ;
             mydata:Column_3 ?Column_3 ;
             mydata:Column_4 ?Column_4 .
        BIND(uuid() AS ?myRowId)
    }
}
```

> Added 1280000 statements. Update took 40s, moments ago.

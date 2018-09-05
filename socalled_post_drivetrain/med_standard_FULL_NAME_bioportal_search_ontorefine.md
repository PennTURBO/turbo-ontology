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

## What's new?

- The best match for each search is now rank #1
- There's a new hit.count property, which indicates if a given search couldn't return 10 hits
- I saved these results from R into TSV and CSV... OntoRefine mangled the TSV import, so used CSV file!
- It doesn't look like the optional wrappers were really needed

```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
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
    SERVICE <ontorefine:1779497362558> {
        ?row a mydata:Row .
        optional {
            ?row mydata:order ?order
        }
        optional {
            ?row mydata:rank ?rank
        }
        optional {
            ?row mydata:hit.count ?hit_count
        }
        optional {
            ?row mydata:prefLabel ?prefLabel 
        }
        optional {
            ?row mydata:id ?id 
        }
        optional {
            ?row mydata:matchType ?matchType .
        }
        optional {
            ?row mydata:ontology ?ontology .
        }
        optional {
            ?row mydata:stringdist ?stringdist .
        }
        BIND(uuid() AS ?myRowId)
    }
}
```

> Added 368 217 statements. Update took 16s, moments ago.

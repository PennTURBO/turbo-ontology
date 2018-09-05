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

There were 4101 unique full names in the med standard table, which became 3969 orders after expansion and lower-casing.  At least one search result/hit was returned for 3960 .

## Which orders didn't get any hits?

```
PREFIX mydata: <http://example.com/resource/>
select 
?full ?expanded (count(distinct ?s3) as ?count)
where {
    graph <http://example.com/resource/med_standard_FULL_NAME_query_expansion>	{
        ?s1 <http://example.com/resource/expanded.query> ?expanded ;
            <http://example.com/resource/FULL_NAME> ?full ;
            <http://example.com/resource/PK_MEDICATION_ID> ?medid .
    } 
    graph <http://example.com/resource/wes_pds_enc__med_order.csv> {
        ?s3 <http://example.com/resource/FK_MEDICATION_ID> ?medid
    }
    minus {
        graph mydata:med_standard_FULL_NAME_bioportal_search
        {
            ?s2 <http://example.com/resource/order> ?expanded .
        }
    }
}
group by ?full ?expanded 
order by desc(count(distinct ?s3))
```

> Showing results from 1 to 19 of 19. Query took 0.2s, moments ago.



full | expanded  |  count
--  |  --  |  --
`ANTITHYMOCYTE   GLOBULIN (RABBIT) IVPB 500ML *PERIPHERAL LINE* ` | ` antithymocyte   globulin (rabbit) injectable solution 500ml *peripheral line* ` | `  26  `
`(Floorstock) ` | ` (floorstock) ` | `  16  `
`ABSORBABLE   HEMOSTAT (SURGICEL) 2\  X 3\  PAD ` | ` absorbable   hemostat (surgicel) 2\  x 3\  pad ` | `  9  `
`ABSORBABLE   HEMOSTAT (SURGICEL) 4\  X 8\  PAD ` | ` absorbable   hemostat (surgicel) 4\  x 8\  pad ` | `  8  `
`ANTITHYMOCYTE   GLOBULIN (RABBIT) IVPB 500ML *CENTRAL LINE* ` | ` antithymocyte   globulin (rabbit) injectable solution 500ml *central line* ` | `  5  `
`NEEDLE (DISP) 30G   X 5/16\  MISC ` | ` needle (disp) 30g   x 5/16\  misc ` | `  3  `
`cholecalciferol_ ` | ` cholecalciferol_ ` | `  2  `
`fexofenadine_ ` | ` fexofenadine_ ` | `  2  `
`insulin glargine   injection * ` | ` insulin glargine   injection * ` | `  2  `
`CURITY   1/2\ X10YD TAPE ` | ` curity   1/2\ x10yd tape ` | `  1  `
`CURITY ABDOMINAL   8\ X10\  PADS ` | ` curity abdominal   8\ x10\  pads ` | `  1  `
`darunavir_ ` | ` darunavir_ ` | `  1  `
`GAUZE PADS &   DRESSINGS 4\ X4\  PADS ` | ` gauze pads &   dressings 4\ x4\  pads ` | `  1  `
`INSULIN SYRINGE   30G X 1/2\  0.5 ML MISC ` | ` insulin syringe   30g x 1/2\  0.5 ml misc ` | `  1  `
`INSULIN   SYRINGE-NEEDLE U-100 28G X 1/2\  1 ML MISC ` | ` insulin   syringe-needle u-100 28g x 1/2\  1 ml misc ` | `  1  `
`LABWORK ` | ` labwork ` | `  1  `
`NEEDLE (DISP) 23G   X 1\  MISC ` | ` needle (disp) 23g   x 1\  misc ` | `  1  `
`SYRINGE/NEEDLE   (DISP) 20G X 1-1/2\  5 ML MISC ` | ` syringe/needle   (disp) 20g x 1-1/2\  5 ml misc ` | `  1  `
`ZYPREXA PO ` | ` zyprexa oral ` | `  1  `




## Histogram of hit counts

```
PREFIX mydata: <http://example.com/resource/>
select ?hit_count (count(distinct(?order)) as ?count) 
where {
    graph mydata:med_standard_FULL_NAME_bioportal_search
    {
        ?myRowId a mydata:Row ;
                 mydata:order ?order ;
                 mydata:hit.count ?hit_count .
    }
}
group by ?hit_count 
order by desc(?hit_count)
```

> Showing results from 1 to 2 of 2. Query took 0.2s, moments ago.

hit_count | count
-|-
3 | 1
10 | 3959



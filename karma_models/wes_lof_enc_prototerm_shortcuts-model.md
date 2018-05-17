# wes_lof_enc_prototerm.csv

## Add Column

## Add Node/Literal

## PyTransforms
#### _allele_info_uri_
From column: _ensgene_
``` python
import uuid
temp = uuid.uuid4().hex
return "alleleInfo/" + temp
```

#### _wes_lof_gene_id_
From column: _ensgene_
``` python
# "TSPAN6(ENSG00000000003)"
# modify R script so that it leaves the original string in the export, instad of reconstructing it here
ensgene_part =  getValue("ensgene")
symbol_part =  getValue("symbol")
return(symbol_part  + "(" + ensgene_part  + ")")
```


## Selections

## Semantic Types
| Column | Property | Class |
|  ----- | -------- | ----- |
| _GENO_ID_ | `ontologies:TURBO_0007602` | `obo:OBI_00013521`|
| _PACKET_UUID_ | `ontologies:TURBO_0007601` | `obo:OBI_00013521`|
| _allele_info_uri_ | `uri` | `obo:OBI_00013521`|
| _term_ | `ontologies:TURBO_0007604` | `obo:OBI_00013521`|
| _wes_lof_gene_id_ | `ontologies:TURBO_0007605` | `obo:OBI_00013521`|
| _zygosity_ | `ontologies:TURBO_0007606` | `obo:OBI_00013521`|


## Links
| From | Property | To |
|  --- | -------- | ---|

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

#### _denoted_reg_uri_
From column: _GENO_ID_
``` python
packval = getValue("PACKET_UUID")

def isint(value):
  try:
    int(value)
    return True
  except ValueError:
    return False

packint = isint(packval)
# integer encounter IDs are indicitive of a CGI encounter
# otherwise PMBB blood?
if packint:
    return("http://transformunify.org/ontologies/TURBO_0000420")
else:
    return("http://transformunify.org/ontologies/TURBO_0000422")
```

#### _zygo_val_spec_
From column: _zygosity_
``` python
zygoval =  getValue("zygosity")
if zygoval == "1":
    return("http://transformunify.org/ontologies/TURBO_0000591")
if zygoval == "2":
    return("http://transformunify.org/ontologies/TURBO_0000590")
```


## Selections

## Semantic Types
| Column | Property | Class |
|  ----- | -------- | ----- |
| _GENO_ID_ | `ontologies:TURBO_0007602` | `obo:OBI_00013521`|
| _PACKET_UUID_ | `ontologies:TURBO_0007601` | `obo:OBI_00013521`|
| _allele_info_uri_ | `uri` | `obo:OBI_00013521`|
| _denoted_reg_uri_ | `ontologies:TURBO_0007603` | `obo:OBI_00013521`|
| _term_ | `ontologies:TURBO_0007604` | `obo:OBI_00013521`|
| _wes_lof_gene_id_ | `ontologies:TURBO_0007605` | `obo:OBI_00013521`|
| _zygo_val_spec_ | `ontologies:TURBO_0007607` | `obo:OBI_00013521`|
| _zygosity_ | `ontologies:TURBO_0007606` | `obo:OBI_00013521`|


## Links
| From | Property | To |
|  --- | -------- | ---|

# wes_lof.L2.M3.forkarma_1_of_10.txt

## Add Column

## Add Node/Literal
#### Literal Node: `eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt`
Literal Type: ``
<br/>Language: ``
<br/>isUri: `false`


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

#### _denoted_bb_enc_id_reg_uri_
From column: _GENO_ID_
``` python
packval = getValue("PROTOCOL")

if packval == "PmbbBlood":
    return "http://transformunify.org/ontologies/TURBO_0000422"
elif packval == "PmbbTissue":
    return "http://transformunify.org/ontologies/TURBO_0000423"
elif packval == "CGI":
    return "http://transformunify.org/ontologies/TURBO_0000420"
else:
    return ""
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

#### _denoted_geno_id_reg_uri_
From column: _GENO_ID_
``` python
return ("http://transformunify.org/ontologies/TURBO_0000451")
```

#### _single_textual_
From column: _ensgene_
``` python
# "TSPAN6(ENSG00000000003)"
# modify R script so that it leaves the original string in the export, instad of reconstructing it here
ensgene_part =  getValue("ensgene")
symbol_part =  getValue("symbol")
zygosity_part =  getValue("zygosity")
return("gene:" + symbol_part  + "(" + ensgene_part  + ");zygosity:" + zygosity_part)
```


## Selections

## Semantic Types
| Column | Property | Class |
|  ----- | -------- | ----- |
| _GENO_ID_ | `ontologies:TURBO_0007602` | `obo:OBI_00013521`|
| _PACKET_UUID_ | `ontologies:TURBO_0007601` | `obo:OBI_00013521`|
| _allele_info_uri_ | `uri` | `obo:OBI_00013521`|
| _denoted_bb_enc_id_reg_uri_ | `ontologies:TURBO_0007609` | `obo:OBI_00013521`|
| _denoted_geno_id_reg_uri_ | `ontologies:TURBO_0007603` | `obo:OBI_00013521`|
| _single_textual_ | `ontologies:TURBO_0007605` | `obo:OBI_00013521`|
| _term_ | `ontologies:TURBO_0007604` | `obo:OBI_00013521`|
| _zygo_val_spec_ | `ontologies:TURBO_0007607` | `obo:OBI_00013521`|


## Links
| From | Property | To |
|  --- | -------- | ---|
| `obo:OBI_00013521` | `ontologies:TURBO_0007608` | `eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt`|

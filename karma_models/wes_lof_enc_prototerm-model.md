# wes_lof_enc_prototerm.csv

## Add Column

## Add Node/Literal

## PyTransforms
#### _zygo_val_spec_1_
From column: _zygosity_
``` python
zygoval =  getValue("zygosity")
if zygoval == "1":
    return("http://transformunify.org/ontologies/TURBO_0000591")
```

#### _zygo_val_spec_2_
From column: _zygo_val_spec_1_
``` python
zygoval =  getValue("zygosity")
if zygoval == "2":
    return("http://transformunify.org/ontologies/TURBO_0000590")
```

#### _coll_proc_uri_
From column: _GENO_ID_
``` python
import uuid
temp = uuid.uuid4().hex
return "collProc/" + temp
```

#### _specimen_uri_
From column: _GENO_ID_
``` python
import uuid
temp = uuid.uuid4().hex
return "specimen/" + temp
```

#### _specimen_crid_symb_uri_
From column: _GENO_ID_
``` python
import uuid
temp = uuid.uuid4().hex
return "specCridSymb/" + temp
```

#### _specimen_crid_uri_
From column: _GENO_ID_
``` python
import uuid
temp = uuid.uuid4().hex
return "specCrid/" + temp
```

#### _dna_extr_proc_uri_
From column: _specimen_crid_uri_
``` python
import uuid
temp = uuid.uuid4().hex
return "dnaExtrProc/" + temp
```

#### _dna_extract_uri_
From column: _specimen_crid_uri_
``` python
import uuid
temp = uuid.uuid4().hex
return "dnaExtract/" + temp
```

#### _seq_proc_uri_
From column: _dna_extract_uri_
``` python
import uuid
temp = uuid.uuid4().hex
return "exonSeqProc/" + temp
```

#### _seq_data_uri_
From column: _seq_proc_uri_
``` python
import uuid
temp = uuid.uuid4().hex
return "seqData/" + temp
```

#### _var_lof_xform_uri_
From column: _seq_data_uri_
``` python
import uuid
temp = uuid.uuid4().hex
return "varLofXformProc/" + temp
```

#### _allele_info_uri_
From column: _var_lof_xform_uri_
``` python
import uuid
temp = uuid.uuid4().hex
return "alleleInf/" + temp
```

#### _dna_uri_
From column: _allele_info_uri_
``` python
import uuid
temp = uuid.uuid4().hex
return "dna/" + temp
```

#### _consenter_uri_
From column: _dna_uri_
``` python
import uuid
temp = uuid.uuid4().hex
return "consenter/" + temp
```

#### _bb_enc_uri_
From column: _PACKET_UUID_
``` python
import uuid
temp = uuid.uuid4().hex
return "bbEnc/" + temp
```

#### _bb_enc_crid_uri_
From column: _PACKET_UUID_
``` python
import uuid
temp = uuid.uuid4().hex
return "bbEncCrid/" + temp
```

#### _bb_enc_symb_uri_
From column: _PACKET_UUID_
``` python
import uuid
temp = uuid.uuid4().hex
return "bbEncSymb/" + temp
```

#### _zygosity_dupe_
From column: _zygosity_
``` python
return getValue("zygosity")
```

#### _wes_lof_gene_id_
From column: _GENO_ID_
``` python
# "TSPAN6(ENSG00000000003)"
ensgene_part =  getValue("ensgene")
symbol_part =  getValue("symbol")
return(symbol_part  + "(" + ensgene_part  + ")")
```

#### _denoted_reg_uri_
From column: _PACKET_UUID_
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

#### _enc_reg_den_uri_
From column: _PACKET_UUID_
``` python
import uuid
temp = uuid.uuid4().hex
return "encRegDen/" + temp
```

#### _genotype_crid_regden_
From column: _GENO_ID_
``` python
import uuid
temp = uuid.uuid4().hex
return "genotypeCridRegden/" + temp
```

#### _genotype_id_reg_
From column: _GENO_ID_
``` python
return "http://transformunify.org/ontologies/TURBO_0000451"
```

#### _dataset_uri_
From column: _ensgene_
``` python
return("http://transformunify.org/dataset/UUID_GOES_HERE")
```

#### _dataset_title_
From column: _ensgene_
``` python
# return the original matrix, or the R transformation
# wes_lof_enc_prototerm.csv
# which included the encounter codes from master_nophi_170419.csv
# and the protein ontology URIs based on
# the ensemble gene ids and or symbols
return("eve.UPENN_Freeze_One.L2.M3.lofMatrix.txt")
```


## Selections

## Semantic Types
| Column | Property | Class |
|  ----- | -------- | ----- |
| _GENO_ID_ | `ontologies:TURBO_0006510` | `ontologies:TURBO_00005681`|
| _PACKET_UUID_ | `ontologies:TURBO_0006510` | `ontologies:TURBO_00005341`|
| _allele_info_uri_ | `uri` | `obo:OBI_00013521`|
| _bb_enc_crid_uri_ | `uri` | `ontologies:TURBO_00005331`|
| _bb_enc_symb_uri_ | `uri` | `ontologies:TURBO_00005341`|
| _bb_enc_uri_ | `uri` | `ontologies:TURBO_00005271`|
| _coll_proc_uri_ | `uri` | `obo:OBI_06000051`|
| _consenter_uri_ | `uri` | `ontologies:TURBO_00005021`|
| _dataset_title_ | `dc:title` | `obo:IAO_00001001`|
| _dataset_uri_ | `uri` | `obo:IAO_00001001`|
| _denoted_reg_uri_ | `uri` | `ontologies:TURBO_00005431`|
| _dna_extr_proc_uri_ | `uri` | `obo:OBI_00002571`|
| _dna_extract_uri_ | `uri` | `obo:OBI_00010511`|
| _dna_uri_ | `uri` | `obo:CHEBI_169911`|
| _enc_reg_den_uri_ | `uri` | `ontologies:TURBO_00005351`|
| _genotype_crid_regden_ | `uri` | `ontologies:TURBO_00005671`|
| _genotype_id_reg_ | `uri` | `ontologies:TURBO_00005651`|
| _seq_data_uri_ | `uri` | `obo:OBI_00015731`|
| _seq_proc_uri_ | `uri` | `obo:OBI_00021181`|
| _specimen_crid_symb_uri_ | `uri` | `ontologies:TURBO_00005681`|
| _specimen_crid_uri_ | `uri` | `ontologies:TURBO_00005661`|
| _specimen_uri_ | `uri` | `obo:OBI_00014791`|
| _term_ | `uri` | `obo:PR_0000000011`|
| _var_lof_xform_uri_ | `uri` | `obo:OBI_02000001`|
| _wes_lof_gene_id_ | `ontologies:TURBO_0006512` | `obo:OBI_00013521`|
| _zygo_val_spec_1_ | `uri` | `ontologies:TURBO_00005711`|
| _zygo_val_spec_2_ | `uri` | `ontologies:TURBO_00005712`|
| _zygosity_ | `ontologies:TURBO_0006512` | `ontologies:TURBO_00005711`|
| _zygosity_dupe_ | `ontologies:TURBO_0006512` | `ontologies:TURBO_00005712`|


## Links
| From | Property | To |
|  --- | -------- | ---|
| `obo:CHEBI_169911` | `obo:BFO_0000050` | `ontologies:TURBO_00005021`|
| `obo:OBI_00002571` | `obo:OBI_0000293` | `obo:OBI_00014791`|
| `obo:OBI_00002571` | `obo:OBI_0000299` | `obo:OBI_00010511`|
| `obo:OBI_00013521` | `obo:OBI_0001938` | `ontologies:TURBO_00005712`|
| `obo:OBI_00013521` | `obo:OBI_0001938` | `ontologies:TURBO_00005711`|
| `obo:OBI_00013521` | `obo:IAO_0000136` | `obo:CHEBI_169911`|
| `obo:OBI_00013521` | `obo:IAO_0000142` | `obo:PR_0000000011`|
| `obo:OBI_00013521` | `obo:BFO_0000050` | `obo:IAO_00001001`|
| `obo:OBI_00021181` | `obo:OBI_0000293` | `obo:OBI_00010511`|
| `obo:OBI_00021181` | `obo:OBI_0000299` | `obo:OBI_00015731`|
| `obo:OBI_02000001` | `obo:OBI_0000299` | `obo:OBI_00013521`|
| `obo:OBI_02000001` | `obo:OBI_0000293` | `obo:OBI_00015731`|
| `obo:OBI_06000051` | `obo:OBI_0000293` | `ontologies:TURBO_00005021`|
| `obo:OBI_06000051` | `obo:BFO_0000050` | `ontologies:TURBO_00005271`|
| `obo:OBI_06000051` | `obo:OBI_0000299` | `obo:OBI_00014791`|
| `ontologies:TURBO_00005021` | `obo:RO_0000056` | `ontologies:TURBO_00005271`|
| `ontologies:TURBO_00005331` | `obo:IAO_0000219` | `ontologies:TURBO_00005271`|
| `ontologies:TURBO_00005341` | `obo:BFO_0000050` | `ontologies:TURBO_00005331`|
| `ontologies:TURBO_00005341` | `obo:BFO_0000050` | `obo:IAO_00001001`|
| `ontologies:TURBO_00005351` | `obo:BFO_0000050` | `ontologies:TURBO_00005331`|
| `ontologies:TURBO_00005351` | `obo:IAO_0000219` | `ontologies:TURBO_00005431`|
| `ontologies:TURBO_00005661` | `obo:IAO_0000219` | `obo:OBI_00014791`|
| `ontologies:TURBO_00005671` | `obo:BFO_0000050` | `ontologies:TURBO_00005661`|
| `ontologies:TURBO_00005671` | `obo:IAO_0000219` | `ontologies:TURBO_00005651`|
| `ontologies:TURBO_00005681` | `obo:BFO_0000050` | `ontologies:TURBO_00005661`|
| `ontologies:TURBO_00005681` | `obo:BFO_0000050` | `obo:IAO_00001001`|
| `ontologies:TURBO_00005711` | `obo:BFO_0000050` | `obo:IAO_00001001`|
| `ontologies:TURBO_00005712` | `obo:BFO_0000050` | `obo:IAO_00001001`|

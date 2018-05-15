# mapped_orders.csv

## Add Column

## Add Node/Literal
#### Literal Node: `mapped_orders.csv 20180329 via wes_pds_enc__med_order.csv`
Literal Type: ``
<p>Language: ``
<p>isUri: `false`


placeholder


## PyTransforms

placeholder


#### _prescription_uri_

placeholder


From column: _PK_ORDER_MED_ID_
``` python
import uuid
temp = uuid.uuid4().hex
return "prescription/" + temp
```

placeholder


#### _enc_uri_

placeholder


From column: _RAWTOHEX.FK_PATIENT_ENCOUNTER_ID._
``` python
encIdVal = getValue("RAWTOHEX.FK_PATIENT_ENCOUNTER_ID.")
return "hcEncounter/" + encIdVal

```

placeholder


#### _encoutner_reg_uri_string_

placeholder


From column: _RAWTOHEX.FK_PATIENT_ENCOUNTER_ID._
``` python
return("http://transformunify.org/ontologies/TURBO_0000440")
```

placeholder


#### _d.full_s_

placeholder


From column: _d.full_s_
``` python
temp =  getValue("d.full_s")
if temp != "NA":
    return(temp)

#return getValue("d.full_s")
```


placeholder


## Selections

placeholder

## Semantic Types

placeholder



| Column | Property | Class |
|  ----- | -------- | ----- |
| _ORDER_NAME_ | `turbo:TURBO_0005611` | `obo:PDRO_00000241`|
| _PK_ORDER_MED_ID_ | `turbo:TURBO_0005601` | `obo:PDRO_00000241`|
| _RAWTOHEX.FK_PATIENT_ENCOUNTER_ID._ | `turbo:TURBO_0000648` | `obo:OGMS_00000971`|
| _d.full_s_ | `turbo:TURBO_0005612` | `obo:PDRO_00000241`|
| _enc_uri_ | `uri` | `obo:OGMS_00000971`|
| _encoutner_reg_uri_string_ | `turbo:TURBO_0000650` | `obo:OGMS_00000971`|
| _prescription_uri_ | `uri` | `obo:PDRO_00000241`|


placeholder


----------

## Links

placeholder


| From | Property | To |
|  --- | -------- | ---|
| `obo:OGMS_00000971` | `obo:RO_0002234` | `obo:PDRO_00000241`|
| `obo:OGMS_00000971` | `turbo:TURBO_0000643` | `mapped_orders.csv 20180329 via wes_pds_enc__med_order.csv`|

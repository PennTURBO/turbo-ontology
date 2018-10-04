1551 unique medication names with RxNorm values from wes_pds__med_standard.csv (no lower-casing, UPHS acronym/abbreviation expansion, or any other tidying... just removal of XL artifacts
- nested commas
- blank lines
- initial and terminal double quotes for strings containing commas

CLAMP semi-structured "medication-attribute" pipeline
running in default GUI mode on Mark's laptop
time: ~ 3 minutes
Number of medications detected

CLAMP and medex provide two levels of specificity for their RxNorm predictions.  Which is more similar with the EPIC annotations?

```
> minimal.mo$Generic.v.PDS <- minimal.mo$Generic == minimal.mo$RXNORM
> table(minimal.mo$Generic.v.PDS, useNA = 'always')

FALSE  TRUE  <NA> 
 1411   172    14 

> minimal.mo$Specific.v.PDS <- minimal.mo$RxNorm == minimal.mo$RXNORM
> table(minimal.mo$Specific.v.PDS, useNA = 'always')

FALSE  TRUE  <NA> 
  641   942    14 
```




There are 170 093 medication names in Nebo's EPIC Med Hierarchy file.
58 282 of those have an RxNorm annotation

Timing for 5000 random RxNorm-annotated medication names from EPIC vs medex: 3 minutes
"EPIC medication hierarchy.xlsx" received on 18. September 2018,at ~ 25 MB.  (Note that there are two different files with the exact same name: one with, and one without RxNorm annotations)

The Medications in this file can have any number of RxNorm annotations (0 to several) at two levels of specificity:  
- medication only
- medication, form and dose

    381 650 rows
    170 093 unique EPIC Medication names
     58 282 with any RxNorm (34%)
     23 072 with a active RxNorm and which don't appear to be combination drugs
    
     15 402 unique "expanded" queries

The Medication names can be down-sampled at this point to speed up the Solr search, but that option  hasn't been applied here

All return at least one Solr hit

Data frame "backmerge":

    582 183 rows of Solr results
     18 859 unique EPIC Medication names that resulted in a active RxNorm prediction via Solr
     15 328 "expanded" queries           that resulted in a active RxNorm prediction via Solr
     14 270 "expanded" queries           that resulted in a active RxNorm prediction via Solr
            AND have some reasonalbe semantic path to the EPIC known RxNorm
      1 058 "expanded" queries           that resulted in a active RxNorm prediction via Solr
            BUT didn't have any reasonalbe semantic path to the EPIC known RxNorm

Randomly select 20% of the EPIC Medication names and set aside all "backmerge" rows using that EPIC Medication names.  They will be used later for coverage calculation.

For the rows using any other EPIC Medication name, down-sample to 10% for faster training and evaluation

80% train, 20% evaluation

Throw out any training features that are correlated >=  0.9 with any other feature

Throw out any training features whose estimated importance is < 0.01 of the most important factor

Train a SVM, just to predict perfect RxNorm matches, on some subset of the "backmerge" rows

- training data volume: 80% of a 10% down-sample of the rows with "non-coverage" EPIC Medication names
- Time: 10 minutes
- Sensitivity: 0.8918716
- Specificity: 0.8326996
- ROC AUC: 0.8562
- coverage: 0.4265252

"Coverage" is defined as the fraction of the set-aside EPIC Medication names that result in at least one TRUE prediction from the machine learner

The SVM can also be trained to 
- independently predict same-parent cases, one-degree-of-separation, or two-degrees-of-separation (multiple binary labels)
- predict a single mulch-level label (the concatenation of the four semantic veracity levels)

Or another machine learner could be used


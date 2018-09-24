when are textual values really required?  only when there may be a need to check the veracity/provenance of a cast variable.  If the shortcuts are created from carnival, using data that has already been typed, maybe we can skip it?

When should transformations take place?  Prescriptions, LOF, etc.?

Likewise, when is a registry denoter required... any time there's a true CRID.  Some of our identifiers may not really be CRIDs?  Again, the CRID registry textual value may not be necessary.

we probably wont be referring to healthcare encounters with PKs... then what?

MAM: Don't forget dataset links

MAM/HGF: Shortcuts and links have to be inserted into particular named graphs

diagnoses AREN'T IDENTIFIED WITH CRIDS ANY MORE.  THE SYMBOL (CODE) AND REGISTRY (ICD VERSION ETC) ARE PART OF THE DIAGNOSIS ITSELF NOW.

ADD TUMOR GRADING NOW AND STAGING ASAP

owl actually expects date-times, not dates.

what is the dataset title if triples came from Carnival?

PREFIX turbo: <http://transformunify.org/ontologies/>
PREFIX pmbb: <http://www.itmat.upenn.edu/biobank/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>


pmbb:73504f4c-8c60-472e-a575-0f6426021ba2 a turbo:TURBO_0000502 ;
        # turbo:TURBO_0000602 "http://purl.obolibrary.org/obo/PATO_0000384"^^xsd:anyURI ;
        # shortcut biobank consenter to biological sex URI string
        # NO, that comes from the conclusionator

turbo:TURBO_0000603 "wes_pds__patient.csv", "Carnival graph" ;
        # shortcut biobank consenter to dataset title
        # PK_PATIENT_ID	EMPI	GID	DOB

turbo:TURBO_0000604 "3/30/70";
        # shortcut biobank consenter to textual date of birth text

turbo:TURBO_0000605 "1970-03-30"^^xsd:date ;
        # shortcut biobank consenter to xsd-formatted date of birth

turbo:TURBO_0000606  "M", "Male" ;
        # shortcut biobank consenter to gender identity datum text

turbo:TURBO_0000607 "http://purl.obolibrary.org/obo/OMRSE_00000141"^^xsd:anyURI ;
        # shortcut biobank consenter to gender identity datum URI string

turbo:TURBO_0000608 "HM123456" ;
        # shortcut biobank consenter to biobank consenter CRID symbol

turbo:TURBO_0000609  "HUP MRN" ;
        # shortcut biobank consenter to biobank consenter registry denoter

turbo:TURBO_0000610"http://transformunify.org/ontologies/TURBO_0000410"^^xsd:anyURI .
        # shortcut biobank consenter to biobank consenter identifier registry URI string

----

turbo:TURBO_0000611
        # shortcut biobank consenter to racial identity registry URI string

turbo:TURBO_0000612
        # shortcut biobank consenter to racial identity registry denoter

turbo:TURBO_0000613
        # shortcut biobank consenter to racial identity CRID symbol

turbo:TURBO_0000614
        # shortcut biobank consenter to racial identity datum URI string

turbo:TURBO_0000615
        # shortcut biobank consenter to racial identity datum veracity

turbo:TURBO_0000616
        # shortcut biobank consenter to racial identity text

----

pmbb:4353f0f4-7c5b-4895-93dd-d79df614d954 a turbo:TURBO_0000502 ;
turbo:TURBO_0000623 "wes_pmbb__enc.csv", "Carnival graph" ;
        # shortcut biobank encounter to data set title
        # PACKETID	PROTOCOL	WEIGHTLBS	HEIGHTINCHES	ENCOUNTERDATE	CALCULATEDBMI


turbo:TURBO_0000624 "6/15/18";
        # shortcut biobank encounter to textual encounter date

turbo:TURBO_0000625  "2018-06-15"^^xsd:date ;
        # shortcut biobank encounter to xsd-formatted  encounter date

    # ADD overall height and weight string(s) shortcuts

turbo:TURBO_0000626 "175.3"^^xsd:float ;
        # shortcut biobank encounter to height in cm

turbo:TURBO_0000627 "74.8"^^xsd:float ;
        # shortcut biobank encounter to weight in kg

turbo:TURBO_0000628 "PB555555" ;
        # shortcut biobank encounter to encounter CRID symbol

turbo:TURBO_0000629 "PmbbBlood" ;
        # shortcut biobank encounter to encounter registry denoter

turbo:TURBO_0000630 "http://transformunify.org/ontologies/TURBO_0000422"^^xsd:anyURI ;
        # shortcut biobank encounter to encounter identifier registry URI string

turbo:TURBO_0000635 "23.6"^^xsd:float .
        # shortcut biobank encounter to BMI

----



pmbb:b2c7d4b6-b625-4772-9687-53e1ef4f76b6 a obo:OGMS_0000097 ;
turbo:TURBO_0000643 "wes_pds__encounter_by_pkpatid.csv", "Carnival graph" ;
        # shortcut health care encounter to data set title
        # EMPI	RAWTOHEX.PK_PATIENT_ENCOUNTER_ID.	ENC_TYPE_CODE	ENC_TYPE_DESCRIPTION	ENC_DATE	HEIGHT_INCHES	WEIGHT_LBS	BMI	PK_PATIENT_ID

turbo:TURBO_0000644 "6/29/18";
        # shortcut health care encounter to textual encounter date

turbo:TURBO_0000645  "2018-06-29"^^xsd:date ;
        # shortcut health care encounter to xsd-formatted encounter date

turbo:TURBO_0000646  "173.9"^^xsd:float ;
        # shortcut health care encounter to height in cm

turbo:TURBO_0000647 "75.2"^^xsd:float ;
        # shortcut health care encounter to weight in kg

turbo:TURBO_0000648 "HCPK987654" ;
        # shortcut health care encounter to encounter ID symbol

turbo:TURBO_0000649 "PDS PDS PK_Encounter_ID" ;
        # shortcut health care encounter to encounter registry denoter

turbo:TURBO_0000650 "http://transformunify.org/ontologies/TURBO_0000440"^^xsd:anyURI ;
        # shortcut health care encounter to encounter identifier registry URI string

turbo:TURBO_0000655  "24.9"^^xsd:float ;
        # shortcut health care encounter to BMI

turbo:TURBO_0000661 "N21.1" ;
        # shortcut health care encounter to diagnosis code symbol

turbo:TURBO_0000662 "ICD10", "ICD-10" ;
        # shortcut health care encounter to diagnosis code registry denoter

turbo:TURBO_0000663 "http://purl.obolibrary.org/obo/NCIT_C128691"^^xsd:anyURI .
        # shortcut health care encounter to diagnosis code registry URI string
        # ICD 10 CM

----

turbo:TURBO_0001603 
        # shortcut biobank encounter CRID to dataset title

turbo:TURBO_0001608 
        # shortcut biobank encounter CRID to biobank encounter CRID symbol

turbo:TURBO_0001609
        # shortcut biobank encounter CRID to biobank encounter registry denoter

turbo:TURBO_0001610
        # shortcut biobank encounter CRID to biobank encounter identifier registry URI string

----


turbo:TURBO_0003603
        # shortcut biobank consenter CRID to dataset title

turbo:TURBO_0003608
        # shortcut biobank consenter CRID to biobank consenter CRID symbol

turbo:TURBO_0003609
        # shortcut biobank consenter CRID to biobank consenter registry denoter

turbo:TURBO_0003610
        # shortcut biobank consenter CRID to biobank consenter identifier registry URI string

----



turbo:TURBO_0001641
        # shortcut health care encounter to drug prescription text

turbo:TURBO_0001642
        # shortcut health care encounter to drug prescription CRID symbol

turbo:TURBO_0002603
        # shortcut health care encounter CRID to dataset title

turbo:TURBO_0002608
        # shortcut health care encounter CRID to health care encounter CRID symbol

turbo:TURBO_0002609
        # shortcut health care encounter CRID to health care encounter registry denoter

turbo:TURBO_0002610
        # shortcut health care encounter CRID to health care encounter identifier registry URI string


----


NOT ACTUALLY USING DIAGNOSIS- OR PRESCRIPTION-BASED SHORTCUTS?  FROM HEALTH CARE ENCOUNTER INSTEAD?

turbo:TURBO_0004601
        # shortcut diagnosis to diagnosis code symbol

turbo:TURBO_0004602
        # shortcut diagnosis to diagnosis code registry denoter

turbo:TURBO_0004603
        # shortcut diagnosis to diagnosis code registry

turbo:TURBO_0004604
        # shortcut diagnosis to data set title


----


turbo:TURBO_0005601
        # shortcut prescription to prescription CRID symbol

turbo:TURBO_0005604
        # shortcut prescription to data set title

turbo:TURBO_0005611
        # shortcut prescription to prescription fullname/order_name

turbo:TURBO_0005612
        # shortcut prescription to drug uri string


----


turbo:TURBO_0007601
        # shortcut allele info to biobank encounter CRID symbol

turbo:TURBO_0007602
        # shortcut allele info to geno_id CRID symbol

turbo:TURBO_0007603
        # shortcut allele info to geno_id registry

turbo:TURBO_0007604
        # shortcut allele info to protein

turbo:TURBO_0007605
        # shortcut allele info to gene text

turbo:TURBO_0007606
        # shortcut allele info to zygosity value text

turbo:TURBO_0007607
        # shortcut allele info to zygosity value specification

turbo:TURBO_0007608
        # shortcut allele info to dataset title

turbo:TURBO_0007609
        # shortcut allele info to biobank encounter CRID registry


----


turbo:TURBO_0007701
        # shortcut racial identity datum to biobank consenter CRID symbol

turbo:TURBO_0007702
        # shortcut racial identity datum to biobank consenter registry denoter

turbo:TURBO_0007703
        # shortcut racial identity datum to biobank consenter identifier registry URI string

turbo:TURBO_0007704
        # shortcut racial identity datum to racial identity CRID symbol

turbo:TURBO_0007705
        # shortcut racial identity datum to racial identity registry denoter

turbo:TURBO_0007706
        # shortcut racial identity datum to racial identity registry URI string

turbo:TURBO_0007707
        <rdfs:comment>have not yet decided if this is necessary... if there is a white racial identity datum about me, is it necessary to say that that datum is true?</rdfs:comment>
        # shortcut racial identity datum to boolean

turbo:TURBO_0007708
        # shortcut racial identity datum to data set title


----


turbo:TURBO_0008601
        # shortcut tumor grading datum to grading process end date

turbo:TURBO_0008602
        # shortcut tumor grading datum to biobank consenter CRID symbol

turbo:TURBO_0008603
        # shortcut tumor grading datum to patient identifier registry text

turbo:TURBO_0008604
        # shortcut tumor grading datum to tissue text

turbo:TURBO_0008605
        # shortcut tumor grading datum to patient identifier registry URI string

turbo:TURBO_0008606
        # shortcut tumor grading datum to grade text

turbo:TURBO_0008607
        # shortcut tumor grading datum to grade URI string


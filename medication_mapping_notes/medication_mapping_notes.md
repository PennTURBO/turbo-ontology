## Migrate *mos*t existing medication related graphs to repo `epic_mdm_ods_20180918`

*The no-inference reasoning level should be fine*

### *Exceptions*

`epic_mdm_ods_20180918` does not yet contain any mapping results, expansion specifications, or expansion results

`epic_meds` still contains http://example.com/resource/EPIC_medex_result_201809161140

`med_orders_ncbo_mappings` still contains

- http://example.com/resource/RxnIfAvailable
- http://example.com/resource/med_standard_FULL_NAME_bioportal_search
- http://example.com/resource/med_standard_FULL_NAME_bioportal_search_semanticTypes
- http://example.com/resource/med_standard_FULL_NAME_query_expansion
- http://example.com/resource/wes_pds_enc__med_order.csv
- http://www.itmat.upenn.edu/biobank/MedMapExpansion
- http://www.itmat.upenn.edu/biobank/knownToMatchedRxnLinkingPred
- http://www.itmat.upenn.edu/biobank/knownToMatchedRxnPred
- http://www.itmat.upenn.edu/biobank/knownToMatchedSameTerm
- http://www.itmat.upenn.edu/biobank/knownToMatchedSharedType

`medications_no_phi` still contains

- http://example.com/resource/fullname_blacklist.csv
- http://example.com/resource/fullname_to_rxn_curations
- http://example.com/resource/medex_results
- http://example.com/resource/uphs_term_expansion.csv

Most likely, these repos also contain medication graphs
- `public_for_turbo`
- `public_for_turbo_20180716_scratch`
- `turbo_6MillLOF_20180622_20180726`
- `turbo_6MillLOF_20180622_20180726_noinf`
- `turbo_6MillLOF_20180622_addl_public_rdfspo`
- `turbo_6MillLOF_20180622_addl_public_rdfspo_scratch`
- `turbo_6MillLOF_20180622_drivetrain_expanded`
- `turbo_6MillLOF_20180622_drivetrain_expanded_scratch`
- `turbo_6MillLOF_20180622_drivetrain_remainder`
- `turbo_6MillLOF_20180622_drivetrain_remainder_scratch`
- `turbo_6MillLOF_20180622_Hayden`
- `turbo_6MillLOF_20180622_restored_20180807`


## Load these via UMLS/MetaMorphoSys -> MySQL -> RDF conversion
- http://data.bioontology.org/ontologies/MDDB/submissions/15/download
- http://data.bioontology.org/ontologies/NDDF/submissions/15/download
- http://data.bioontology.org/ontologies/NDFRT/submissions/15/download
- http://data.bioontology.org/ontologies/SNOMEDCT/submissions/15/download
- http://data.bioontology.org/ontologies/VANDF/submissions/15/download

### Minimal UMLS -> RDF instructions:
- Get a UMLS license
    - https://www.nlm.nih.gov/databases/umls.html
- Download UMLS (get the latest release... except the latest release to contain MMDB was 2017AA)
    - https://www.nlm.nih.gov/research/umls/licensedcontent/umlsknowledgesources.html
- Extract the desired content to RRF with MetaMorphoSys
    - https://www.ncbi.nlm.nih.gov/books/NBK9683/
- Download and install MySQL if necessary
- Create an empty database
    - https://www.digitalocean.com/community/tutorials/how-to-create-and-manage-databases-in-mysql-and-mariadb-on-a-cloud-server
- Create a superuser
    - https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql
- Load the RRF files into MySQL
    - https://www.nlm.nih.gov/research/umls/implementation_resources/scripts/README_RRF_MySQL_Output_Stream.html 
- *Despite the warning, I haven't found any problem with using the latest MySQL with the default InnoDB settings.*
- Cun the RDF creation scripts
    - https://github.com/ncbo/umls2rdf


## Load these via web downloads
- ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi_lite.owl.gz 
- https://bitbucket.org/uamsdbmi/dron/raw/master/dron-chebi.owl
- https://bitbucket.org/uamsdbmi/dron/raw/master/dron-hand.owl
- https://bitbucket.org/uamsdbmi/dron/raw/master/dron-ingredient.owl
- https://bitbucket.org/uamsdbmi/dron/raw/master/dron-ndc.owl
- https://bitbucket.org/uamsdbmi/dron/raw/master/dron-pro.owl
- https://bitbucket.org/uamsdbmi/dron/raw/master/dron-rxnorm.owl
- https://bitbucket.org/uamsdbmi/dron/raw/master/dron-upper.owl
- http://data.bioontology.org/ontologies/RXNORM/submissions/15/download

## Load these via OntoRefine
### Directly from CSV, with zero or minimal manipulation or deviation from default OntoRefine settings.  

*Each CSV file is obviously inserted into a separate named graph, and UUIDs are generally used for the OntoRefine row URIs instead of the suggested value-based row URIs*

- **http://example.com/resource/epic_meds_with_rxnorm**

*Didn't name the graph after the file (`EPIC medication hierarchy.xlsx`) dues to the spaces in the name.*

```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
    graph mydata:mdm_ods_merged_meds.csv {
        ?myRowId a mydata:mdm_medication ;
            mydata:PK_MEDICATION_ID ?PK_MEDICATION_ID ;
            mydata:FULL_NAME ?FULL_NAME ;
            mydata:PHARMACY_CLASS ?PHARMACY_CLASS ;
            mydata:SIMPLE_GENERIC_NAME ?SIMPLE_GENERIC_NAME ;
            mydata:GENERIC_NAME ?GENERIC_NAME ;
            mydata:THERAPEUTIC_CLASS ?THERAPEUTIC_CLASS ;
            mydata:PHARMACY_SUBCLASS ?PHARMACY_SUBCLASS ;
            mydata:AMOUNT ?AMOUNT ;
            mydata:FORM ?FORM ;
            mydata:ROUTE_DESCRIPTION ?ROUTE_DESCRIPTION ;
            mydata:ROUTE_TYPE ?ROUTE_TYPE ;
            mydata:CONTROLLED_MED_YN ?CONTROLLED_MED_YN ;
            mydata:DEA_CLASS ?DEA_CLASS ;
            mydata:RECORD_STATE ?RECORD_STATE ;
            mydata:FK_3M_NCID_ID ?FK_3M_NCID_ID ;
            mydata:RXNORM ?RXNORM ;
            mydata:RXNORM_DEFINITION ?RXNORM_DEFINITION ;
            mydata:MDM_LAST_UPDATE_DATE ?MDM_LAST_UPDATE_DATE ;
            mydata:MDM_INSERT_UPDATE_FLAG ?MDM_INSERT_UPDATE_FLAG ;
            mydata:ods.SOURCE_CODE ?ods_SOURCE_CODE ;
            mydata:mdm.ods.same.FULL_NAME ?mdm_ods_same_FULL_NAME .
    }
} WHERE {
    SERVICE <ontorefine:1722969636564> {
        ?row a mydata:Row ;
             mydata:PK_MEDICATION_ID ?PK_MEDICATION_ID ;
             mydata:FULL_NAME ?FULL_NAME ;
             mydata:PHARMACY_CLASS ?PHARMACY_CLASS ;
             mydata:SIMPLE_GENERIC_NAME ?SIMPLE_GENERIC_NAME ;
             mydata:GENERIC_NAME ?GENERIC_NAME ;
             mydata:THERAPEUTIC_CLASS ?THERAPEUTIC_CLASS ;
             mydata:PHARMACY_SUBCLASS ?PHARMACY_SUBCLASS ;
             mydata:AMOUNT ?AMOUNT ;
             mydata:FORM ?FORM ;
             mydata:ROUTE_DESCRIPTION ?ROUTE_DESCRIPTION ;
             mydata:ROUTE_TYPE ?ROUTE_TYPE ;
             mydata:CONTROLLED_MED_YN ?CONTROLLED_MED_YN ;
             mydata:DEA_CLASS ?DEA_CLASS ;
             mydata:RECORD_STATE ?RECORD_STATE ;
             mydata:FK_3M_NCID_ID ?FK_3M_NCID_ID ;
             mydata:RXNORM ?RXNORM ;
             mydata:RXNORM_DEFINITION ?RXNORM_DEFINITION ;
             mydata:MDM_LAST_UPDATE_DATE ?MDM_LAST_UPDATE_DATE ;
             mydata:MDM_INSERT_UPDATE_FLAG ?MDM_INSERT_UPDATE_FLAG ;
             mydata:ods.SOURCE_CODE ?ods_SOURCE_CODE ;
             mydata:mdm.ods.same.FULL_NAME ?mdm_ods_same_FULL_NAME .
        BIND(uuid() AS ?myRowId)
    }
}
```

> Approximately 20M statements in 40 minutes

*Purged literal objects with value "-" (used to indicate NA?) after the fact.*


```
PREFIX mydata: <http://example.com/resource/>
delete {
    graph mydata:mdm_ods_merged_meds.csv {
        ?s ?p "NA"
    }    
} where {
    graph mydata:mdm_ods_merged_meds.csv {
        ?s ?p "NA"
    }
}

```

> Removed 11909031 statements. Update took 1m 41s, moments ago.
 

- **http://example.com/resource/wes_pds_enc__med_order.csv**

*Encounter IDs have been removed from the http://example.com/resource/wes_pds_enc__med_order.csv graph included in `epic_mdm_ods_20180918`, so this is a password-free, PHI-free repository.*


```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
    graph mydata:wes_pds_enc__med_order.csv   
    {
        ?myRowId a mydata:med_order ;
            mydata:PK_ORDER_MED_ID ?PK_ORDER_MED_ID ;
            mydata:ORDER_NAME ?ORDER_NAME ;
            mydata:FK_MEDICATION_ID ?FK_MEDICATION_ID ;
            mydata:DOSE ?DOSE ;
            mydata:FREQUENCY_NAME ?FREQUENCY_NAME ;
            mydata:QUANTITY ?QUANTITY ;
            mydata:REFILLS ?REFILLS ;
            mydata:UNIT_OF_MEASURE ?UNIT_OF_MEASURE ;
            mydata:LOCATION_CODE ?LOCATION_CODE ;
            mydata:LOCATION_DESCRIPTION ?LOCATION_DESCRIPTION ;
            mydata:ORDER_DATE ?ORDER_DATE ;
            mydata:ORDER_GROUP ?ORDER_GROUP ;
            mydata:ORDER_PRIORITY_DESC_NONSTD ?ORDER_PRIORITY_DESC_NONSTD ;
            mydata:ORDER_PRIORITY_DESCRIPTION ?ORDER_PRIORITY_DESCRIPTION .
    }
} 
WHERE {
    SERVICE <ontorefine:2509688580914> {
        ?row a mydata:Row ;
             mydata:PK_ORDER_MED_ID ?PK_ORDER_MED_ID .
        optional {
            ?row mydata:ORDER_NAME ?ORDER_NAME .
        }
        optional {
            ?row mydata:FK_MEDICATION_ID ?FK_MEDICATION_ID .
        }
        optional {
            ?row mydata:DOSE ?DOSE .
        }
        optional {
            ?row mydata:FREQUENCY_NAME ?FREQUENCY_NAME .
        }
        optional {
            ?row mydata:QUANTITY ?QUANTITY .
        }
        optional {
            ?row mydata:REFILLS ?REFILLS .
        }
        optional {
            ?row mydata:UNIT_OF_MEASURE ?UNIT_OF_MEASURE .
        }
        optional {
            ?row mydata:LOCATION_CODE ?LOCATION_CODE .
        }
        optional {
            ?row mydata:LOCATION_DESCRIPTION ?LOCATION_DESCRIPTION .
        }
        optional {
            ?row mydata:ORDER_DATE ?ORDER_DATE .
        }
        optional {
            ?row mydata:ORDER_GROUP ?ORDER_GROUP .
        }
        optional {
            ?row mydata:ORDER_PRIORITY_DESC_NONSTD ?ORDER_PRIORITY_DESC_NONSTD .
        }
        optional {
            ?row mydata:ORDER_PRIORITY_DESCRIPTION ?ORDER_PRIORITY_DESCRIPTION .
        }
        BIND(uuid() AS ?myRowId)
    }
}

```

> Added approximately 1400000 statements in 3m 


- **http://example.com/resource/epic_meds_with_rxnorm_valcasts**

*Medication IDs from http://example.com/resource/epic_meds_with_rxnorm were cast to integers and RxNorm values were cast to URIs.*

```
PREFIX mydata: <http://example.com/resource/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
insert {
    graph mydata:epic_meds_with_rxnorm_valcasts {
        ?s mydata:MEDICATION_ID_INT ?epicMedId ;
            mydata:RXNORM_CODE_URI ?epicRxnUri .
    }
}
where {
    graph <http://example.com/resource/epic_meds_with_rxnorm> {
        ?s  mydata:RXNORM_CODE ?epicRxn ;
            mydata:MedicationName ?epicMedName ;
            mydata:MEDICATION_ID ?epicMedIdFloat .
        bind(xsd:integer(?epicMedIdFloat) as ?epicMedId)
        bind(uri(concat("http://purl.bioontology.org/ontology/RXNORM/", ?epicRxn)) as ?epicRxnUri)
    }
}
```

> Added 522772 statements. Update took 9.1s, moments ago.


- **http://example.com/resource/curated_roles**

*To address false negatives when comparing EPIC roles to TURBO roles: ChEBI is missing some (reasonable) analgesic roles known to EPIC.*

- Oxymorphone
- Oxymorphone HCl
- Meperidine
- tapentadol
- magmesium salicylate
- +/- menthol
- Sodium thiosalicylate
- ziconotide
- pentazocine

```
    # No path to liposomal morphine yet
    # Benzocaine = otic analgesic ?!
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    insert data {
        graph <http://example.com/resource/curated_roles> {
            <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> a <http://www.w3.org/2002/07/owl#Restriction>;
                <http://www.w3.org/2002/07/owl#onProperty> <http://purl.obolibrary.org/obo/RO_0000087>;
                <http://www.w3.org/2002/07/owl#someValuesFrom> <http://purl.obolibrary.org/obo/CHEBI_35482> ;
                rdfs:comment "EPIC (reasonably) considers the following analgesiscs: Oxymorphone, Oxymorphone hcl, Meperidine, tapentadol, magmesium salicylate, +/- menthol, Sodium thiosalicylate, ziconotide,pentazocine.  ChEBI doesn't. " .
            <http://purl.obolibrary.org/obo/CHEBI_7865> <http://www.w3.org/2000/01/rdf-schema#subClassOf>
                    <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> .
            <http://purl.obolibrary.org/obo/CHEBI_7866> <http://www.w3.org/2000/01/rdf-schema#subClassOf>
                    <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> .
            <http://purl.obolibrary.org/obo/CHEBI_6754> <http://www.w3.org/2000/01/rdf-schema#subClassOf>
                    <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> .
            <http://purl.obolibrary.org/obo/CHEBI_135935> <http://www.w3.org/2000/01/rdf-schema#subClassOf>
                    <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> .
            <http://purl.obolibrary.org/obo/CHEBI_6640> <http://www.w3.org/2000/01/rdf-schema#subClassOf>
                    <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> .
            <http://purl.obolibrary.org/obo/CHEBI_76310> <http://www.w3.org/2000/01/rdf-schema#subClassOf>
                    <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> .
            <http://purl.obolibrary.org/obo/CHEBI_9182> <http://www.w3.org/2000/01/rdf-schema#subClassOf>
                    <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> .
            <http://purl.obolibrary.org/obo/CHEBI_135912> <http://www.w3.org/2000/01/rdf-schema#subClassOf>
                    <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> .
            <http://purl.obolibrary.org/obo/CHEBI_7982> <http://www.w3.org/2000/01/rdf-schema#subClassOf>
                    <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> .
        }
    }

```

- **http://example.com/resource/normalized_supplementary_mappings**

*To address false negatives when comparing EPIC roles to TURBO roles:  The NCBO BioPortal mappings don't include the follwoing RxNorm/ChEBI pairs:*
- aspirin/acetylsalicylic acid
- acetaminophen/paracetamol
- methol/(+/-) menthol

```
insert data {
    graph <http://example.com/resource/normalized_supplementary_mappings> {
        <http://example.com/resource/1f755a19-1603-4f38-a36f-8dda60f238b8> a <http://example.com/resource/Row>;
            <http://example.com/resource/matchOnt> <http://data.bioontology.org/ontologies/CHEBI>;
            <http://example.com/resource/matchTerm> <http://purl.obolibrary.org/obo/CHEBI_46195>;
            <http://example.com/resource/rxnormInput> <http://purl.bioontology.org/ontology/RXNORM/161> .
        <http://example.com/resource/34ad7f5f-5148-4e5d-8624-cfb059b9a86b> a <http://example.com/resource/Row>;
            <http://example.com/resource/matchOnt> <http://data.bioontology.org/ontologies/CHEBI>;
            <http://example.com/resource/matchTerm> <http://purl.obolibrary.org/obo/CHEBI_76310>;
            <http://example.com/resource/rxnormInput> <http://purl.bioontology.org/ontology/RXNORM/6750> .
        <http://example.com/resource/35261041-04e1-48d6-88cf-b12691b99c0b> a <http://example.com/resource/Row>;
            <http://example.com/resource/matchOnt> <http://data.bioontology.org/ontologies/CHEBI>;
            <http://example.com/resource/matchTerm> <http://purl.obolibrary.org/obo/CHEBI_15365>;
            <http://example.com/resource/rxnormInput> <http://purl.bioontology.org/ontology/RXNORM/1191> .
    }
```

- *http://example.com/resource/mdm_ods_merged_meds.csv*

*The ODS file (at least) has to be opened with codepage 1252 encoding.  Only the source column from ODS was retained.  There are 62 rows where the pre-tidied MDM medication names don't match the raw ODS medication names.*


```
library(readr)
mdm.auth.fn <-
  "c:/Users/Mark Miller/Desktop/med_authorities/mdm_r_medication_180917.csv"
mdm.auth <-
  read_csv(mdm.auth.fn, locale = locale(encoding = "WINDOWS-1252"))
dim(mdm.auth)
ods.auth.fn <-
  "c:/Users/Mark Miller/Desktop/med_authorities/ods_r_medication_source_180917.csv"
ods.auth <-
  read_csv(ods.auth.fn, locale = locale(encoding = "WINDOWS-1252"))
dim(ods.auth)
ods.auth.minimal <-
  ods.auth[, c("PK_MEDICATION_ID", "FULL_NAME", "SOURCE_CODE")]

merged <-
  merge(
    x = mdm.auth,
    y = ods.auth.minimal,
    by = "PK_MEDICATION_ID",
    all = TRUE,
    suffixes = c(".mdm", ".ods")
  )

merged$same.text = merged$FULL_NAME.mdm == merged$FULL_NAME.ods

table(merged$same.text)

write.csv(x = merged,
          file = "mdm_ods_merged_meds.csv",
          row.names = FALSE)
```

- **http://example.com/resource/bioportal_mappings.tsv**

First, you'll need a BioPortal API key.  See https://bioportal.bioontology.org/help#Getting_an_API_key

Then pipe the output of this script to a text file.

```
import urllib.request, urllib.error, urllib.parse
import json

REST_URL = "http://data.bioontology.org"
API_KEY = "<that's secret>"

sourceOntoAbbr = "RXNORM"
constrainDestOnto = False
#destOntoUriList   = ["http://data.bioontology.org/ontologies/SNOMEDCT"]

PAGE_SIZE = 500
	
def get_json(url):
    opener = urllib.request.build_opener()
    opener.addheaders = [('Authorization', 'apikey token=' + API_KEY)]
    return json.loads(opener.open(url).read())
page = get_json(REST_URL+"/ontologies/" + sourceOntoAbbr + "/mappings?pagesize=" + str(PAGE_SIZE ))
	
pagecount = page["pageCount"]
next_page = page
while next_page:
    for ndfrt_mapping in page["collection"]:
        mapsource = ndfrt_mapping["source"]
        internal = ndfrt_mapping["classes"][0]["@id"]
        external = ndfrt_mapping["classes"][1]["@id"]
        extont = ndfrt_mapping["classes"][1]["links"]["ontology"]
        if ((extont in destOntoUriList) or (not constrainDestOnto)):
            combo = internal + "\t" + mapsource + "\t" +  extont + "\t" + external
            print(combo)
    next_page = page["links"]["nextPage"]
    if next_page:
        page = get_json(next_page)
		
```

Fianlly, use that text file as the input into a OntoRefine project.  Insert the triples like this:

```
PREFIX mydata: <http://example.com/resource/>
PREFIX spif: <http://spinrdf.org/spif#>
insert {
    graph mydata:bioportal_mappings.tsv {
        ?myRowId a <http://example.com/resource/bioportal_mapping> ;
            mydata:inputTerm ?Column_1 ;
            mydata:matchMeth ?Column_2 ;
            mydata:matchOnt ?Column_3 ;
            mydata:matchTerm ?Column_4 ;
            mydata:sourceOnt <http://data.bioontology.org/ontologies/RXNORM> .
    }
} WHERE {
    SERVICE <ontorefine:2278478571415> {
        ?row a mydata:Row ;
             mydata:Column_1 ?Column_1 ;
             mydata:Column_2 ?Column_2 ;
             mydata:Column_3 ?Column_3 ;
             mydata:Column_4 ?Column_4 .
        BIND(uuid() AS ?myRowId)
    }
}
```

> Added 1536000 statements. Update took 48s, minutes ago.


- *http://example.com/resource/wes_pds__med_standard.csv*

*The CSV file has 15458 rows, many of which are duplicates (see PK_MEDICATION_ID = 98.)  The graph only contains triples about the 4104 unique rows.  Used an MD5 of the PK for the row URIs to force non-redundancy?  May be superseded by http://example.com/resource/mdm_ods_merged_meds.csv?*

- BACKED-UP/DELETED *http://example.com/resource/mdm_meds*
    subset of http://example.com/resource/normalized_supplementary_mappings)
- BACKED-UP/DELETED *http://example.com/resource/rxnorm_bioportal_mappings*
    subset of http://example.com/resource/bioportal_mappings.tsv

----

### Mapping approaches
- Solr vs *manipulated* DRON
- NCBO BioPortal search API vs all BioPortal content
- medex
- CLAMP
- Lucene (built into GraphDB) vs the ontologies producing the most RxNorm hits with the all-BioPortal technique
- (External) Solr vs ontologies producing the most RxNorm hits...



## QC Queries

### Of the medications with EPIC-known RxNorm values, which have a semantic path to ChEBI's analgesic role?

```
    PREFIX lucene: <http://www.ontotext.com/connectors/lucene#>
    PREFIX inst: <http://www.ontotext.com/connectors/lucene/instance#>
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    PREFIX rxnorm: <http://purl.bioontology.org/ontology/RXNORM/>
    PREFIX umls: <http://bioportal.bioontology.org/ontologies/umls/>
    PREFIX mydata: <http://example.com/resource/>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX owl: <http://www.w3.org/2002/07/owl#>
    PREFIX obo: <http://purl.obolibrary.org/obo/>
    PREFIX : <http://www.ontotext.com/connectors/lucene#>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    select  
    distinct ?epicMedId ?epicMedName ?chebilab ?irlab
    where {
        graph <ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi_lite.owl.gz> {
            ?immediateRole rdfs:subClassOf* obo:CHEBI_35480 ;
                                          rdfs:label ?irlab .
        }
        {
            {
                graph <http://example.com/resource/curated_roles> {
                    ?restr owl:someValuesFrom ?immediateRole ;
                           a owl:Restriction ;
                           owl:onProperty obo:RO_0000087 .
                    ?chebiterm rdfs:subClassOf ?restr .
                }
            }
            union
            {
                graph <ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi_lite.owl.gz> {
                    ?restr owl:someValuesFrom ?immediateRole ;
                           a owl:Restriction ;
                           owl:onProperty obo:RO_0000087 .
                    ?chebiterm rdfs:subClassOf ?restr .
                }
            }
        }
        graph <ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology/chebi_lite.owl.gz> {
            ?immediateRole rdfs:label ?irlab .
            ?chebiterm rdfs:label ?chebilab .
        }
        {
            {
                graph 	mydata:bioportal_mappings.tsv {
                    ?bpmapped mydata:matchTerm ?chebiterm ;
                              mydata:inputTerm ?expanded3  ;
                              mydata:sourceOnt <http://data.bioontology.org/ontologies/RXNORM> ;
                              mydata:matchOnt <http://data.bioontology.org/ontologies/CHEBI> .
                } 
            } union         {
                graph 	<http://example.com/resource/normalized_supplementary_mappings> {
                    ?bpmapped mydata:matchTerm ?chebiterm ;
                              mydata:rxnormInput ?expanded3  ;
                              mydata:matchOnt <http://data.bioontology.org/ontologies/CHEBI> .
                } 
            }
        }
        #    #    values (?userMedInput ?minLucScore) {
        #    #        ("oxycodone tabs" 7 )
        #    #    }
        values (?expPred1 ?expPred2) {
            ( rxnorm:consists_of	rxnorm:has_ingredient )
            ( rxnorm:consists_of	rxnorm:has_precise_ingredient )
            ( rxnorm:has_ingredient	rxnorm:has_precise_ingredient )
            ( rxnorm:has_ingredient	rxnorm:tradename_of )
            ( rxnorm:has_ingredients	rxnorm:has_part )
            ( rxnorm:has_part	rxnorm:form_of )
            ( rxnorm:has_part	rxnorm:has_form )
            ( rxnorm:has_precise_ingredient	rxnorm:form_of )
            #        ( rxnorm:has_tradename	rxnorm:has_precise_ingredient )
            ( rxnorm:ingredient_of	rxnorm:has_precise_ingredient )
            ( rxnorm:isa	rxnorm:has_ingredient )
            ( rxnorm:precise_ingredient_of	rxnorm:has_ingredient )
            ( rxnorm:precise_ingredient_of	rxnorm:has_precise_ingredient )
            ( rxnorm:quantified_form_of	rxnorm:has_ingredient )
            ( rxnorm:tradename_of	rxnorm:has_form )
        }
        graph <http://data.bioontology.org/ontologies/RXNORM/submissions/15/download> {
            {
                {
                    ?epicRxnormUri  ?expPred1 ?expanded2 ;
                                    skos:prefLabel ?expLab1 .
                    ?expanded2 ?expPred2 ?expanded3 ;
                               skos:prefLabel ?expLab2 .
                    ?expanded3 skos:prefLabel ?expLab3 .
                }
                union {
                    ?epicRxnormUri  ?expPred1 ?expanded3 ;
                                    skos:prefLabel ?expLab1 .
                    ?expanded3 skos:prefLabel ?expLab3 .
                }            
                union {
                    ?epicRxnormUri  skos:notation ?sharednotation  ;
                                    skos:prefLabel ?expLab1 .
                    ?expanded3   skos:notation ?sharednotation ;
                                 skos:prefLabel ?expLab3 .
                }
            }
            optional {
                ?epicRxnormUri  umls:hasSTY ?sty1 .
                ?sty1 skos:prefLabel ?typelab1 .
            }
            optional {
                ?expanded3  umls:hasSTY ?sty3 .
                ?sty3 skos:prefLabel ?typelab3 .
            }
        }
        graph mydata:epic_meds_with_rxnorm_valcasts {
            ?epicMed mydata:RXNORM_CODE_URI    ?epicRxnormUri ;
                     mydata:MEDICATION_ID_INT ?epicMedId .
        }
        graph mydata:epic_meds_with_rxnorm  {
            ?epicMed rdf:type mydata:epic_med ;
                     mydata:MedicationName ?epicMedName ;
                     mydata:RXNORM_CODE_LEVEL  ?epicMedRxnLev ;
                     }
        #    #    ?luceneSearch a inst:EpicMedicationName ;
        #    #                  lucene:query ?userMedInput ;
        #    #                  # lucene:limit "1" ;
        #    #                  lucene:entities ?epicMed .
        #    #    ?epicMed lucene:score ?luceneScore .
        #    #    filter (?luceneScore > ?minLucScore)
    }
```

Now compare to the EPIC categories.  Could probably do that in the graph.  This example exports to a file and does the comparison, agisnt the EPIC meds file, in R.

```
    options(java.parameters = "- Xmx8g")
    
    library(readxl)
    library(readr)
    library(xlsx)
    library(caret)
    library(IRanges)
    library(reshape)
    
    setwd("c:/Users/Mark Miller/Desktop/med_authorities/")
    
    epic.auth.fn <- "EPIC medication hierarchy.xlsx"
    epic.auth <- read_xlsx(epic.auth.fn)
    
    epic2chebi_analgesics <-
      read_csv("C:/Users/Mark Miller/Desktop/epic2chebi_analgesics.csv")
    
    merged <- merge(
      x = epic.auth,
      y = epic2chebi_analgesics,
      by.x = "MEDICATION_ID",
      by.y = "epicMedId",
      all = TRUE
    )
    
    merged <- merged[merged$RXNORM_CODE != "-" ,]
      
    blankcounts <- lapply(epic.auth[], function(one.col) {
      inner <- one.col == "-"
      return(sum(inner))
    })
    blankcounts <-
      cbind.data.frame(names(blankcounts), as.numeric(blankcounts))
    
    levelcounts  <- lapply(epic.auth[], function(one.col) {
      inner <- length(unique(one.col))
      return(sum(inner))
    })
    levelcounts <-
      cbind.data.frame(names(levelcounts), as.numeric(levelcounts))
    
    drugcounts  <- table(merged$chebilab)
    drugcounts <-
      cbind.data.frame(names(drugcounts), as.numeric(drugcounts))
    
    topclasscounts  <- table(merged$PharmacyClass)
    topclasscounts <-
      cbind.data.frame(names(topclasscounts), as.numeric(topclasscounts))
    
    
    subclasscounts  <- table(merged$PharmacySubClass)
    subclasscounts <-
      cbind.data.frame(names(subclasscounts), as.numeric(subclasscounts))
    
    
    therapycounts  <- table(merged$TherapyClass)
    therapycounts <-
      cbind.data.frame(names(therapycounts), as.numeric(therapycounts))
    
    
    crosscheck <-
      as.data.frame.matrix(table(merged$PharmacySubClass, merged$irlab))
    
    temp <-
      unique(tolower(c(
        unique(merged$PharmacyClass),
        unique(merged$PharmacySubClass),
        unique(merged$TherapyClass)
      )))
    temp.flag  <-
      grepl(pattern = "analgesic",
            x = temp,
            ignore.case = TRUE)
    temp <- cbind.data.frame(temp, temp.flag)
    
    all.greppable.cats <-
      c(
        "analgesics-nonnarcotic",
        "analgesics-narcotic",
        "analgesics other",
        "analgesic combinations",
        "otic analgesics",
        "urinary analgesics",
        "analgesics - topical",
        "analgesics-peptide channel blockers",
        "analgesics - anti-inflammatory combinations",
        "analgesics & anesthetics"
      )
    
    allowed <-
      c(
        "analgesics-nonnarcotic",
        "analgesics-narcotic",
        "analgesics other",
        "analgesic combinations",
        "otic analgesics",
        "urinary analgesics",
        "analgesics - topical",
        "analgesics - anti-inflammatory combinations"
      )
    
    omitted <- setdiff(all.greppable.cats, allowed)
    
    
    parent.flag <-
      tolower(as.character(merged$PharmacyClass)) %in% allowed
    
    sub.flag <-
      tolower(as.character(merged$PharmacySubClass)) %in% allowed
    
    therapy.flag <-
      tolower(as.character(merged$TherapyClass)) %in% allowed
    
    any.flag <- cbind.data.frame(parent.flag, sub.flag, therapy.flag)
    any.flag <- rowSums(any.flag)
    any.flag <- any.flag > 0
    
    merged$epic.analgesic.flag <- any.flag
    
    merged$turbo.analgesic.flag <- !is.na(merged$irlab)
    
    merged$mismatch.bool <-
      merged$epic.analgesic.flag != merged$turbo.analgesic.flag
    
    merged$mismatch.text <- 'consensus'
    merged$mismatch.text[merged$mismatch.bool &
                           merged$epic.analgesic.flag] <- 'EPIC only'
    merged$mismatch.text[merged$mismatch.bool &
                           merged$turbo.analgesic.flag] <- 'TURBO only'
    
    # which?
    for.caret <-
      table(merged$epic.analgesic.flag, merged$turbo.analgesic.flag)
    sensitivity(for.caret)
    specificity(for.caret)
    for.caret <-
      table(merged$turbo.analgesic.flag, merged$epic.analgesic.flag)
    sensitivity(for.caret)
    specificity(for.caret)
    
    
    check.by.subclass <-
      as.data.frame.matrix(table(merged$PharmacySubClass , merged$mismatch.text, useNA = 'ifany'))
    
    
    check.by.chebi.comp <-
      as.data.frame.matrix(table(merged$chebilab , merged$mismatch.text, useNA = 'ifany'))
    
    # save.image("210809201015.Rdata")
    
    epic.detective <-
      merged[merged$mismatch.text == "EPIC only" &
               merged$PharmacySubClass == "Analgesics Other", ]
    epic.detective <- table(epic.detective$RXNORM_CODE)
    epic.detective <-
      cbind.data.frame(names(epic.detective), as.numeric(epic.detective))
    
    turbo.detective <-
      table(merged$chebilab[merged$mismatch.text == "TURBO only"])
    
    turbo.detective <-
      cbind.data.frame(names(turbo.detective), as.numeric(turbo.detective))
    
    turbo.detective <-
      table(merged$chebilab[merged$mismatch.text == "TURBO only"],
            merged$PharmacySubClass[merged$mismatch.text == "TURBO only"])
    
    turbo.detective <- as.data.frame(turbo.detective)
    turbo.detective <- turbo.detective[turbo.detective$Freq > 0 , ]
```

Look for cases in which TURBO considers a medication to be an analgeic, but EPIC doesn't. (Including rows with `TURBO only` counts down to 1% of the "worst offender", paracetamol [aceaminophen].)

medication | consensus | EPIC only | TURBO only
-- | -- | -- | --
paracetamol | 6372 | 0 | 15376
hydrocodone | 1033 | 0 | 4403
menthol | 518 | 0 | 4364
codeine | 547 | 0 | 3542
ibuprofen | 108 | 0 | 1148
capsaicin | 0 | 0 | 1023
naproxen.sodium | 0 | 0 | 698
antipyrine | 0 | 0 | 658
magnesium.sulfate | 0 | 0 | 593
acetylsalicylic.acid | 3083 | 0 | 487
naproxen | 0 | 0 | 459
ergotamine | 0 | 0 | 454
ketorolac.tromethamine | 0 | 0 | 452
lamotrigine | 0 | 0 | 231
ketorolac | 0 | 0 | 207
diclofenac | 0 | 0 | 200
carbamazepine | 0 | 0 | 176

Now look for any case in which EPIC and TURBO disagree about whether a medication is an analgesic.   (Including rows with `non-narcotic analgesic` counts down to 1% of the "worst offender", Cough/Cold/Allergy Combinations.)

EPIC PharmacySubClass | analgesic | non-narcotic analgesic | opioid analgesic
-- | -- | -- | --
Cough/Cold/Allergy   Combinations | 0 | 15154 | 7815
Analgesic Combinations | 666 | 3948 | 144
Opioid Combinations | 298 | 2396 | 3035
Analgesics Other | 0 | 2042 | 13
Nonsteroidal   Anti-inflammatory Agents (NSAIDs) | 441 | 1649 | 0
Salicylates | 0 | 1560 | 248
Antihistamine Hypnotics | 0 | 923 | 0
Local Anesthetics - Topical | 0 | 787 | 1083
Migraine Combinations | 0 | 690 | 0
Urinary Analgesics | 0 | 424 | 0
Otic Combinations | 0 | 309 | 309
Anticonvulsants - Misc. | 70 | 300 | 0
Liniments | 0 | 278 | 1243
Muscle Relaxant Combinations | 0 | 183 | 21


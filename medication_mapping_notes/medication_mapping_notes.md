## Migrate **most** existing medication related graphs to repo `epic_mdm_ods_20180918`

### Exceptions

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



- **http://example.com/resource/mdm_ods_merged_meds.csv**

*The ODS file (At least) has to be opened with codepage 1252 encoding.  Only the source column from ODS was retained.  There are 62 rows where the pre-tidied MDM medication names don't match the raw ODS medication names.*


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


- **http://example.com/resource/curated_roles**

*To address false negatives when comparing EPIC roles to TURBO roles: ChEBI is missing some (reasoanble) analgesic toles known to EPIC.*

```
    # No path to liposomal morphine yet
    # Benzocaine = otic analgesic ?!
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    insert data {
        graph <http://example.com/resource/curated_roles> {
            <http://example.com/resource/6ec7eb6e-150f-479c-9e77-f24e79ae3ba4> a <http://www.w3.org/2002/07/owl#Restriction>;
                <http://www.w3.org/2002/07/owl#onProperty> <http://purl.obolibrary.org/obo/RO_0000087>;
                <http://www.w3.org/2002/07/owl#someValuesFrom> <http://purl.obolibrary.org/obo/CHEBI_35482> ;
                rdfs:comment "EPIC (reaonably) considers the following analgesiscs: Oxymorphone, Oxymorphone hcl, Meperidine, tapentadol, magmesium salicylate, +/- menthol, Sodium thiosalicylate, ziconotide,pentazocine.  ChEBI doesn't. " .
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

- *http://example.com/resource/rxnorm_bioportal_mappings*

- *http://example.com/resource/wes_pds__med_standard.csv*

*The CSV file has 15458 rows, many of which are duplicates (see PK_MEDICATION_ID = 98.)  The graph only contains triples about the 4104 unique rows.  Used an MD5 of the PK for the row URIs to force non-redundancy?  My be superseded by http://example.com/resource/mdm_ods_merged_meds.csv?*

- *http://example.com/resource/mdm_meds*



----

### Mapping approaches
- Solr vs *manipulated* DRON
- NCBO BioPortal search API vs all BioPortal content
- medex
- CLAMP
- Lucene (built into GraphDB) vs the ontologies producing the most RxNorm hits with the all-BioPortal technique
- (External) Solr vs ontologies producing the most RxNorm hits...

----


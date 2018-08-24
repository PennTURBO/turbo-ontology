# Using BioPortal APIs to map medication strings to ontology terms 

This article describes a way to retrieve suggested ontology terms based on textual input, like one would find in  the `full_name`s column from the PDS table `med_standard`.  The route from this mapping back to a patient will go through the med_order table, which indicates the encounter that the order belongs to.  All intermediate data described here goes straight into the graph, so there's no need for passing CSV files around. This worked example uses OntoRefine to insert the intermediate data into the graph, but a Scala application could do the insertions via RDF4J.  (It should be reasonable to implement all of this within Scala and eliminate the dependence on any R code.)  The classes and properties currently in use in these intermediate graphs are not defined in the TURBO ontology and could be considered cryptic or inconsistent.  It's expected that the nature of the intermediate graphs may change when re-implemented in Scala.  If necessary, more rigor can be applied to the terms used in the intermediate graphs.

The ultimate goal of this approach is to identify one high-confidence term from a realism-based ontology for each prescription ordered for the patients within the scope of a given GraphDB repo.

The methods described here do not currently (late August 2018) complete that task, but suggestions are available for completing the last steps.  This method returns matching terms from any ontology in the BioPortal.  Those are frequently from RxNorm, and when they're not, the can frequently be mapped to RxNorm with a second API call.  Since some med_standard entries are already annotated with RxNorm values, tests are in place to determine whether APE-returned RxNorm values are identical, subClasses of the same parent class, or related in some other way by a single relationship.  Those facts could be taken as labels for training a machine learning algorithm to discriminate  correct string-to-term mappings.  It's unclear whether these techniques will work for non-medication orders like "wheelchair".

Since DRON terms have RxNorm values, it won't be difficult to map most of the orders to DRON and then on to ChEBI.  This will mostly be limited by the age of the most recent DRON ("new" prescriptions being more likely to fall through the cracks) and by the fact that DRON created its own terms for modeling some active pharmaceutical ingredients (rosuvastatin) when a term for the same thing already existed in ChEBI.

Additional benefit:  with this workflow, incremental near-real-time updates will be available for all steps beside a yet-to-be-built ML filter for valid/invalid search results.

## Ontologies and linked data sets to be loaded up front

(See repo med_orders_ncbo_mappings.  In general, give the graph the same name as the source file.  Obtaining RDF files from the BioPortal requires constructing a URI with the latest submission and an apikey, which has to be requested at https://bioportal.bioontology.org/help#Getting_an_API_key)

The latest submission can be obtained from the REST API (http://data.bioontology.org/documentation#Ontology).  Here's an R example:

```
library(jsonlite)
apikey <- 'secret'
ontology.abbreviation <- 'ICD10CM'
ontology.summary <-
  fromJSON(
    paste0(
      'http://data.bioontology.org/ontologies/',
      ontology.abbreviation ,
      '/latest_submission?apikey=',
      apikey
    )
  )
print(ontology.summary[['submissionId']])
```

http://data.bioontology.org/ontologies/RXNORM/submissions/<latest_submission>/download?apikey=<apikey_from_properties_file> into https://bioportal.bioontology.org/ontologies/RXNORM

DRONs

ChEBI

others for non-drug prescriptions

instantiate health care prescription

## Workflow

1. retrieve all unique med_standard full_names that are to be mapped.  These can be obtained from shortcut or expanded triples that are already in the graph.  (Not described yet.)  The *sample* R code inserts `wes_pds_enc__med_order.csv` and `wes_pds__med_standard.csv` into graphs http://example.com/resource/wes_pds_enc__med_order.csv and http://example.com/resource/wes_pds__med_standard.csv with OntoRefine.
2. "expand" (or modify) the orders to replace UPHS-favored terms (PO tab) with language that appears more frequently in BioPortal/RxNorm term labels (oral tablet).  The (regular expression) expansion rules are manually curated and can be found in graph http://www.itmat.upenn.edu/biobank/MedMapExpansion  Metrics aren't available yet for how much benefit comes from the expansion, but it was qualitatively important in the older R/Solr approach.  
    - The *sample* R code demonstrates the expansion and several subsequent steps, like quality assessments that show which ontologies have the most high-ranking hits, and which full_name terms might still benefit from expansion.
    - The path from a patient to terms representing their prescriptions will need to traverse the results of the expansion, which are modeled in graph http://example.com/resource/med_standard_FULL_NAME_query_expansion
    - That graph was populated by instantiating output from the sample R script with https://github.com/PennTURBO/Turbo-Ontology/blob/master/socalled_post_drivetrain/med_standard_FULL_NAME_query_expansion_ontorefine.md
3. submit the expanded med_standard full_names to the BioPortal search API.  The example code retrieves up to 10 hits for each term and records their ranks (10 being the term appearing first in the BioPortal result.  It does not appear that any quantitative confidence score is available.)  Maybe the ranking should be reversed so that the first hit is 1, especially since some input terms won't retrieve 10 hits.  The example code also calculates the string similarity between the input med_standard full_names and the labels of the suggested terms.  Solr scores and string similarities weren't instantiated after the previous R/Solr/SVM approach, but we probably should get in the habit of instantiating the rank, similarity and future ML confidence score.
     - Example OntoRefine graph:  http://example.com/resource/med_standard_FULL_NAME_bioportal_search 
     - Example OntoRefine SPARQL: https://github.com/PennTURBO/Turbo-Ontology/blob/master/socalled_post_drivetrain/med_standard_FULL_NAME_bioportal_search_ontorefine.md
4.  Included in the search results are Concept Unique Identifiers and Semantic Type values for each suggested term.  The example R code breaks those out into separate data structures.  Nothing is specifically being done with the CUI values yet.  They are available from each ontology, like RxNorm. The semantic type data **is** inserted into a separate named graph because it might be useful for training a ML filter... some types may turn out to be "wrong" more often than not.
    - Example OntoRefine graph:  http://example.com/resource/med_standard_FULL_NAME_bioportal_search_semanticTypes
    - https://github.com/PennTURBO/Turbo-Ontology/blob/master/socalled_post_drivetrain/med_standard_FULL_NAME_bioportal_search_semanticTypes_ontorefine.md
    - Example OntoRefine SPARQL: https://github.com/PennTURBO/Turbo-Ontology/blob/master/socalled_post_drivetrain/med_standard_FULL_NAME_bioportal_search_semanticTypes_ontorefine.md
    - graph https://www.nlm.nih.gov/research/umls/META3_current_semantic_types.html contains triples about all of the semantic types, whether they are instantiated in any of the medication mapping results or now.  It was created by converting UMLS RRF to MySQL and then to RDF, which will eventually be described elsewhere.  It is probably not an essential part of this workflow.  A RDF file of the semantic types may be publicly available elsewhere.
4. Independently from the previous steps, use the the BioPortal mapping API to gather all terms from all ontologies that have RxNorm equivalents.  
    - The example code in https://github.com/PennTURBO/Turbo-Ontology/blob/master/utility_python/get_bioportal_rxnorm_mappings.py dumps the mappings to STDOUT with tab as the delimiter.  (It takes a minute or so before the first batch comes out.)  
    - Example OntoRefine graph:  http://example.com/resource/rxnorm_bioportal_mappings  
    - Example OntoRefine SPARQL: https://github.com/PennTURBO/Turbo-Ontology/blob/master/socalled_post_drivetrain/rxnorm_bioportal_mappings_ontorefine.md
1. Create triples that say what RxNorm value is available via the search, whether it was a direct search result, or whether it was found by mapping a non-RxNorm term to RxNorm.  If no RxNorm term is available by either of those routes, use the URI for the direct search result.
    - Example **non**-OntoRefine SPARQL: https://github.com/PennTURBO/Turbo-Ontology/blob/master/socalled_post_drivetrain/RxnIfAvailable.md
    - Resulting graph: http://example.com/resource/RxnIfAvailable
1. Insert some more triples regarding the acceptability of search results, in the cases where PDS already had a RxNorm value.  These could be used for training a ML filter.
    - does the RxNorm term from the search result exactly match the PDS-provided RxNorm value, including the cases where the additional mapping was required?
    - do the search-result RxNorm term and the PDS RxNorm value have a common parent?
    - is there some other direct relationship between the two RxNorm terms?
1. Now do some queries!
2. http://www.itmat.upenn.edu/biobank/knownToMatchedSameTerm
3. 





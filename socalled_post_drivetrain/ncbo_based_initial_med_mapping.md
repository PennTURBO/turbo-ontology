# Using BioPortal APIs to map medication strings to ontology terms 

This article describes a way to retrieve suggested ontology terms based on textual input, like one would find in  the `full_name`s column from the PDS table `med_standard`.  The route from this mapping back to a patient will go thorough the med_order table, which indicates the encounter that the order belongs to.  All intermediate data described here goes straight into the graph, so there's no need for passing CSV files around. This worked example uses OntoRefine to insert the intermediate data into the graph, but a Scala application could do the insertions via RDF4J.  (It should be reasonable to implement all of this within Scala and eliminate the dependence on any R code.)  The classes and properties currently in use in these intermediate graphs are not defined in the TURBO ontology and could be considered cryptic or inconsistent.  It's expected that the nature of the intermediate graphs may change when re-implemented in Scala.  If necessary, more rigor can be applied to the terms used in the intermediate graphs.

The ultimate goal of this approach is to identify one high-confidence term from a realism-based ontology for each prescription ordered for the patients within the scope of a given GraphDB repo.

The methods described here do not currently (late August 2018) complete that task, but suggestions are available for completing the last steps.  This method returns matching terms from any ontology in the BioPortal.  Those are frequently from RxNorm, and when they're not, the can frequently be mapped to RxNorm with a second API call.  Since some med_standard entries are already annotated with RxNorm values, tests are in place to determine whether APE-returned RxNorm values are identical, subClasses of the same parent class, or related in some other way by a single relationship.  Those facts could be taken as labels for training a machine learning algorithm to discriminate  correct string-to-term mappings.  It's unclear whether these techniques will work for non-medication orders like "wheelchair".

Since DRON terms have RxNorm values, it won't be difficult to map most of the orders to DRON and then on to ChEBI.  This will mostly be limited by the age of the most recent DRON ("new" prescriptions being more likely to fall through the cracks) and by the fact that DRON created its own terms for modeling some active pharmaceutical ingredients (rosuvastatin) when a term for the same thing already existed in ChEBI.

Ontologies and linked data sets to be loaded up front:

http://data.bioontology.org/ontologies/RXNORM/submissions/<latest_submission>/download?apikey=<apikey_from_properties_file> into https://bioportal.bioontology.org/ontologies/RXNORM





1. retrieve all unique med_standard full_names that are to be mapped.  These can be obtained from shortcut or expanded triples that are already in the graph.  (Not described yet.)  The sample R code inserts wes_pds_enc__med_order.csv and wes_pds__med_standard.csv into graphs http://example.com/resource/wes_pds_enc__med_order.csv and http://example.com/resource/wes_pds__med_standard.csv with OntoRefine.
2. "expand" (or modify) the orders to replace UPHS-favored terms (PO tab) with language that appears more frequently in BioPortal/RxNorm term labels (oral tablet).  The expansion rules are part of the graph.  Metrics aren't available yet for how much benefit comes from the expansion, but it was qualitatively important in the older R/Solr approach.  Some *sample* R code (https://github.com/PennTURBO/Turbo-Ontology/blob/master/utility_r/ncbo_med_search.R) is available to demonstrate the expansion and several subsequent steps.  This code also generates some quality assessments that show which ontologies have the most high-ranking hits and what full_name terms might still benefit from expansion.
3. submit the expanded med_standard full_names to the BioPortal search API.  The example code retrieves up to 10 hits for each term and records their ranks (10 being the term appearing first in the BioPortal result.  It does not appear that any quantitative confidence score is available.)  Maybe the ranking should be reversed so that the first hit is 1, especially since some input terms won't retrieve 10 hits.  The example code also calculates the string similarity between the input med_standard full_names and the labels of the suggested terms.  Included in the search results are Concept Unique Identifiers and Semantic Type values for each suggested term.  The example code breaks that out into a separate data structure which is inserted into a separate named graph.
4. Independently from the previous steps, use the the BioPortal mapping API to gather all terms from all ontologies that have RxNorm equivalents.  Example code = .  Current graph = http://example.com/resource/rxnorm_bioportal_mappings  Example SPARQL = 



incremental


As of it doesn't do any quality filtering.


Previous approach
R
SVM
CSV
med_order order_name

retain confidence values
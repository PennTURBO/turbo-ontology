## Customize Makefile settings for turbo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


# ----------------------------------------
# Standard Constants
# ----------------------------------------
# these can be overwritten on the command line

$(IMPORTDIR)/obib_import.owl: $(MIRRORDIR)/obib.owl $(IMPORTDIR)/obib_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/obib_terms_combined.txt --force true --intermediates minimal --copy-ontology-annotations true --individuals include --method STAR \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/htn_import.owl: $(MIRRORDIR)/htn.owl $(IMPORTDIR)/htn_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/htn_terms_combined.txt --force true --intermediates minimal --copy-ontology-annotations true --individuals include --method STAR \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/osci_import.owl: $(MIRRORDIR)/osci.owl $(IMPORTDIR)/osci_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/osci_terms_combined.txt --force true --intermediates minimal --copy-ontology-annotations true --individuals include --method STAR \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/obi_import.owl: $(MIRRORDIR)/obi.owl $(IMPORTDIR)/obi_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/obi_terms_combined.txt --force true --intermediates minimal --copy-ontology-annotations true --individuals include --method STAR \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/omrse_import.owl: $(MIRRORDIR)/omrse.owl $(IMPORTDIR)/omrse_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/omrse_terms_combined.txt --force true --intermediates minimal --copy-ontology-annotations true --individuals include --method STAR \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/ogms_import.owl: $(MIRRORDIR)/ogms.owl $(IMPORTDIR)/ogms_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/ogms_terms_combined.txt --force true --intermediates minimal --copy-ontology-annotations true --individuals include --method STAR \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/pdro_import.owl: $(MIRRORDIR)/pdro.owl $(IMPORTDIR)/pdro_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/pdro_terms_combined.txt --force true --lower-terms $(IMPORTDIR)/pdro_terms.txt --copy-ontology-annotations true --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/ncbitaxon_import.owl: $(MIRRORDIR)/ncbitaxon.owl $(IMPORTDIR)/ncbitaxon_terms_combined.txt
	if [ $(IMP) = true ] && [ $(IMP_LARGE) = true ]; then $(ROBOT) extract -i $< -T $(IMPORTDIR)/ncbitaxon_terms_combined.txt --force true --upper-terms $(IMPORTDIR)/ncbitaxon_terms.txt --lower-term NCBITaxon:9606 --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/mondo_import.owl: $(MIRRORDIR)/mondo.owl $(IMPORTDIR)/mondo_terms_combined.txt
	if [ $(IMP) = true ] && [ $(IMP_LARGE) = true ]; then $(ROBOT) extract -i $< -T $(IMPORTDIR)/mondo_terms_combined.txt --force true --lower-term MONDO:0004992 --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/chebi_import.owl: $(MIRRORDIR)/chebi.owl $(IMPORTDIR)/chebi_terms_combined.txt
	if [ $(IMP) = true ] && [ $(IMP_LARGE) = true ]; then $(ROBOT) extract -i $< -T $(IMPORTDIR)/chebi_terms_combined.txt --force true --lower-terms $(IMPORTDIR)/chebi_terms.txt --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/pr_import.owl: $(MIRRORDIR)/pr.owl $(IMPORTDIR)/pr_terms_combined.txt
	if [ $(IMP) = true ] && [ $(IMP_LARGE) = true ]; then $(ROBOT) extract -i $< -T $(IMPORTDIR)/pr_terms_combined.txt --force true --lower-terms $(IMPORTDIR)/pr_terms.txt --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/go_import.owl: $(MIRRORDIR)/go.owl $(IMPORTDIR)/go_terms_combined.txt
	if [ $(IMP) = true ] && [ $(IMP_LARGE) = true ]; then $(ROBOT) extract -i $< -T $(IMPORTDIR)/go_terms_combined.txt --force true --lower-terms $(IMPORTDIR)/go_terms.txt --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/ico_import.owl: $(MIRRORDIR)/ico.owl $(IMPORTDIR)/ico_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/ico_terms_combined.txt --force true --lower-terms $(IMPORTDIR)/ico_terms.txt --copy-ontology-annotations true --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/cl_import.owl: $(MIRRORDIR)/cl.owl $(IMPORTDIR)/cl_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/cl_terms_combined.txt --force true --lower-terms $(IMPORTDIR)/cl_terms.txt --copy-ontology-annotations true --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/pato_import.owl: $(MIRRORDIR)/pato.owl $(IMPORTDIR)/pato_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/pato_terms_combined.txt --force true --lower-terms $(IMPORTDIR)/pato_terms.txt --copy-ontology-annotations true --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

$(IMPORTDIR)/uberon_import.owl: $(MIRRORDIR)/uberon.owl $(IMPORTDIR)/uberon_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/uberon_terms_combined.txt --force true --lower-terms $(IMPORTDIR)/uberon_terms.txt --copy-ontology-annotations true --individuals include --method MIREOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

## Customize Makefile settings for turbo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

# ----------------------------------------
# Standard Constants
# ----------------------------------------
# these can be overwritten on the command line

URIBASE=                    http://purl.obolibrary.org/obo
ONT=                        turbo
ONTBASE=                    $(URIBASE)/$(ONT)
EDIT_FORMAT=                owl
SRC =                       $(ONT)-edit.$(EDIT_FORMAT)
CATALOG=                    catalog-v001.xml
ROBOT=                      robot --catalog $(CATALOG)

OWLTOOLS=                   owltools --use-catalog
RELEASEDIR=                 ../..
REPORTDIR=                  reports
TEMPLATEDIR=                ../templates
TMPDIR=                     tmp
SCRIPTSDIR=                 ../scripts
SPARQLDIR =                 ../sparql
COMPONENTSDIR =             components
REPORT_FAIL_ON =            None
REPORT_LABEL =              -l true
REPORT_PROFILE_OPTS =       
OBO_FORMAT_OPTIONS =        
SPARQL_VALIDATION_CHECKS =   equivalent-classes owldef-self-reference
SPARQL_EXPORTS =             basic-report class-count-by-prefix edges xrefs obsoletes synonyms
ODK_VERSION_MAKEFILE =      v1.2.32

TODAY ?=                    $(shell date +%Y-%m-%d)
OBODATE ?=                  $(shell date +'%d:%m:%Y %H:%M')
VERSION=                    $(TODAY)
ANNOTATE_ONTOLOGY_VERSION = annotate -V $(ONTBASE)/releases/$(VERSION)/$@ --annotation owl:versionInfo $(VERSION)
OTHER_SRC =                 
ONTOLOGYTERMS =             $(TMPDIR)/ontologyterms.txt

FORMATS = $(sort  owl obo owl)
FORMATS_INCL_TSV = $(sort $(FORMATS) tsv)
RELEASE_ARTEFACTS = $(sort $(ONT)-full $(ONT)-base $(ONT)-base $(ONT)-full)

IMPORTS =  pdro ncbitaxon

IMPORT_ROOTS = $(patsubst %, imports/%_import, $(IMPORTS))
IMPORT_OWL_FILES = $(foreach n,$(IMPORT_ROOTS), $(n).owl)
IMPORT_FILES = $(IMPORT_OWL_FILES)

.PHONY: all_imports
all_imports: $(IMPORT_FILES)

## ONTOLOGY: pdro
## Copy of pdro is re-downloaded whenever source changes
mirror/pdro.trigger: $(SRC)

mirror/pdro.owl: mirror/pdro.trigger
	if [ $(MIR) = true ] && [ $(IMP) = false ]; then curl -L $(URIBASE)/pdro.owl --create-dirs -o mirror/pdro.owl --retry 4 --max-time 200 && $(ROBOT) convert -i mirror/pdro.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/pdro.owl

IMP_LARGE=false # Global parameter to bypass handling of large imports

## ONTOLOGY: ncbitaxon
## try effect of bypassing large imports
mirror/ncbitaxon.trigger: $(SRC)

mirror/ncbitaxon.owl: mirror/ncbitaxon.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(URIBASE)/ncbitaxon.owl --create-dirs -o mirror/ncbitaxon.owl --retry 4 --max-time 200 && $(ROBOT) convert -i mirror/ncbitaxon.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/ncbitaxon.owl

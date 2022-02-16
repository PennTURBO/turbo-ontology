---
layout: ontology_detail
id: turbo
title: TURBO ontology
jobs:
  - id: https://travis-ci.org/PennTURBO/turbo-ontology
    type: travis-ci
build:
  checkout: git clone https://github.com/PennTURBO/turbo-ontology.git
  system: git
  path: "."
contact:
  email: 
  label: 
  github: 
description: TURBO ontology is an ontology...
domain: stuff
homepage: https://github.com/PennTURBO/turbo-ontology
products:
  - id: turbo.owl
    name: "TURBO ontology main release in OWL format"
  - id: turbo.obo
    name: "TURBO ontology additional release in OBO format"
  - id: turbo.json
    name: "TURBO ontology additional release in OBOJSon format"
  - id: turbo/turbo-base.owl
    name: "TURBO ontology main release in OWL format"
  - id: turbo/turbo-base.obo
    name: "TURBO ontology additional release in OBO format"
  - id: turbo/turbo-base.json
    name: "TURBO ontology additional release in OBOJSon format"
dependencies:
- id: ro
- id: bfo
- id: iao
- id: pdro

tracker: https://github.com/PennTURBO/turbo-ontology/issues
license:
  url: http://creativecommons.org/licenses/by/3.0/
  label: CC-BY
activity_status: active
---

Enter a detailed description of your ontology here. You can use arbitrary markdown and HTML.
You can also embed images too.


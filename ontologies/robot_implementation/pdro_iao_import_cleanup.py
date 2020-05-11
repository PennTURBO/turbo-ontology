#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri May  8 16:29:45 2020

@author: markampa
"""

import shutil
import tempfile

# currently editing in place (old content ends up in a temp file
# should probably keep the old and the new, in sperate folders)

# PROBLEM_FILE = "/Users/markampa/Turbo-Ontology/ontologies/animals_robot_transition/ontology_downloads/hado.owl"
PROBLEM_FILE = "/Users/markampa/Turbo-Ontology/ontologies/animals_robot_transition/ontology_downloads/pdro.owl"

temp_file = tempfile.NamedTemporaryFile()
print(temp_file.name)

shutil.copyfile(PROBLEM_FILE, temp_file.name)

# put something in place for applying sever fixes
# shouldn't we be able to do this with a catalog?

BAD_IAO_URL = 'http://purl.obolibrary.org/obo/iao/iao-edit.owl'
GOOD_IAO_URL = 'https://raw.githubusercontent.com/information-artifact-ontology/IAO/master/iao.owl'

bad_rocore_url = 'http://purl.obolibrary.org/obo/ro/core-subset.owl'
good_rocore_url = 'http://purl.obolibrary.org/obo/ro/core.owl'


fin = open(temp_file.name, "rt")
fout = open(PROBLEM_FILE, "wt")
for line in fin:
    # print(line)
    temp = line.replace(BAD_IAO_URL, GOOD_IAO_URL)
    temp = temp.replace(bad_rocore_url, good_rocore_url)
    fout.write(temp)

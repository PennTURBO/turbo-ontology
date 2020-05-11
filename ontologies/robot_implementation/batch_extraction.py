# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import os
import subprocess
from os import listdir

ART_PATH = '/Users/markampa/Turbo-Ontology/ontologies/animals_robot_transition'
TERMLIST_PATH = os.path.join(ART_PATH, 'term_lists')
ONTO_DL_PATH = os.path.join(ART_PATH, 'ontology_downloads')
EXTRACTION_OUPUT_PATH = os.path.join(ART_PATH, 'extracts')

included_extensions = ['.owl.txt']

# termlist_filenames = [f for f in listdir(TERMLIST_PATH) if isfile(join(TERMLIST_PATH, f))]

termlist_filenames_as_is = [fn for fn in listdir(TERMLIST_PATH)
                      if any(fn.endswith(ext) for ext in included_extensions)]

termlist_filenames = sorted(termlist_filenames_as_is)

ontology_abbreviations = [sub.replace('.owl.txt', '') for sub in termlist_filenames]

ROBOT_PATH = '/usr/local/bin/robot'

num_ontologies = len(termlist_filenames)

for i in range(0, num_ontologies):
    # print(i)
    current_onto_abbrev = ontology_abbreviations[i]
    current_onto_file = current_onto_abbrev+".owl"
    current_termlist_file = current_onto_abbrev+".owl.txt"
    current_extract_file = current_onto_abbrev+".extract.ttl"
    print(current_onto_file)
    robot_array = [ROBOT_PATH,
               "extract",
               "--individuals", "include",
               "--method", "BOT",
               "--force", "true",
               "--verbose",
               "--intermediates", "all",
               "--annotate-with-source", "true",
               "--input",
               os.path.join(ONTO_DL_PATH, current_onto_file),
               "--term-file",
               os.path.join(TERMLIST_PATH, current_termlist_file),
               "--output",
               os.path.join(EXTRACTION_OUPUT_PATH, current_extract_file)]
    robot_call = subprocess.run(robot_array,
                            stdout=subprocess.PIPE,
                            text=True,
                            check=True)
    print(robot_call.stdout)
    # print(robot_call.stderr)

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 22 08:42:44 2020

@author: markampa
"""

import os
import pandas as pd
from datetime import datetime
import subprocess
from os import listdir
import glob

# import requests
# import re

# timeit ?

abbrev_byte_est_file = 'obo_abbreviations_byte_estimates.csv'

non_obo_url_file = 'non_obo_urls.txt'

max_estimate = 10000000000

ART_PATH = '.'
TERMLIST_DIR = 'term_lists'
ONTO_DL_DIR = 'ontology_downloads'
EXTRACTION_OUPUT_DIR = 'extracts'

included_extensions = ['.owl.txt']

ROBOT_PATH = '/usr/local/bin/robot'

# ROBOT_PATH = 'export ROBOT_JAVA_ARGS=-Xmx4G && /usr/local/bin/robot'

merge_output_file = 'merged_extracts.ttl'

turbo_UNmerged_ontology_file = 'turbo_unmerged.ttl'

turbo_with_extracts_ontology_file = 'turbo_with_extracts.ttl'

turbo_merged_ontology_file = 'turbo_merged.ttl'

turbo_reasoned_ontology_file = 'turbo_merged_inferred.ttl'

more_specimens_tsv_file = 'more-specimens.tsv'

more_specimens_ontology_url = "https://raw.githubusercontent.com/" + \
    "PennTURBO/loinc_in_obo/master/more-specimens.ttl"

more_specimens_annotations_file = "more-specimens_annotations.ttl"

more_specimens_ontology_output_file = "more-specimens.ttl"

####

the_cwd = os.getcwd()

abbrev_byte_est = \
    pd.read_csv(abbrev_byte_est_file)

# for col in abbrev_byte_est.columns:
#     print(col)

smaller_obo_ontologies = \
    abbrev_byte_est[abbrev_byte_est.loc[:,
                                        'bytes_estimate'] <= max_estimate]

obo_abbreviation_list = smaller_obo_ontologies['obo_abbreviation'].tolist()

obo_url_prefix = 'http://purl.obolibrary.org/obo/'

with open(non_obo_url_file) as my_file:
    non_obo_url_list = my_file.readlines()

TERMLIST_PATH = os.path.join(ART_PATH, TERMLIST_DIR)
ONTO_DL_PATH = os.path.join(ART_PATH, ONTO_DL_DIR)
EXTRACTION_OUPUT_PATH = os.path.join(ART_PATH, EXTRACTION_OUPUT_DIR)

termlist_filenames_as_is = [fn for fn in listdir(TERMLIST_PATH)
                            if any(fn.endswith(ext) for ext in
                            included_extensions)]

termlist_filenames = sorted(termlist_filenames_as_is)

ontology_abbreviations = [sub.replace('.owl.txt', '') for sub in
                          termlist_filenames]

num_ontologies = len(termlist_filenames)


def incremental_merging(incremental_array):
    incremental_interleaved = [ROBOT_PATH, 'merge']
    array_size = len(incremental_array)
    for i in range(0, array_size):
        current_incremented = incremental_array[i]
        # print(current_incremented)
        incremental_interleaved.append('--input')
        incremental_interleaved.append(current_incremented)
    incremental_interleaved.append('--output')
    incremental_interleaved.append(incremental_file)
    print('merge string built')
    return(incremental_interleaved)


def reason_helper(ontology_file):
    # print(ontology_file)
    command_array = [
        ROBOT_PATH,
        "reason",
        "--reasoner",
        "hermit",
        "--input",
        ontology_file
        ]
    # print(command_array)
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    print("Current Time =", current_time)
    try:
        robot_call = \
            subprocess.run(
                command_array, stdout=subprocess.PIPE, text=True,
                check=True)
        print(robot_call.stdout)
        print(robot_call.stderr)
    except Exception:
        print('\nROBOT ERROR... possible ontology inconsistency')
    print('reasoning complete')


incremental_file = "incremental.ttl"

try:
    os.remove(incremental_file)
except Exception:
    print("Error while deleting file: ", incremental_file)

ttl_dir = os.path.join(ART_PATH, EXTRACTION_OUPUT_DIR)

ttl_files = glob.glob(ttl_dir+'/*.ttl')

pairs = []

for current_ttl in ttl_files:
    size = os.path.getsize(current_ttl)
    pairs.append((size, current_ttl))

pairs.sort(key=lambda s: s[0])

incremental_list = []


for pair in pairs:
    current_onto_file = pair[1]
    current_onto_size = pair[0]
    print("Current file: " + current_onto_file)
    print("Current file size: " + str(current_onto_size))
    reason_helper(current_onto_file)
    incremental_list.append(current_onto_file)
    # print(incremental_list)
    inclilen = len(incremental_list)
    # print(inclilen)
    if inclilen > 1:
        # print('multiple')
        merge_cmd = incremental_merging(incremental_list)
        print(merge_cmd)
        try:
            robot_call = \
                subprocess.run(
                    merge_cmd,
                    stdout=subprocess.PIPE, text=True, check=True)
            print(robot_call.stdout)
            print(robot_call.stderr)
        except Exception:
            print('\nROBOT ERROR merging')
        print("Merged file size: " + str(os.path.getsize(incremental_file)))
        reason_helper(incremental_file)
    print('.')

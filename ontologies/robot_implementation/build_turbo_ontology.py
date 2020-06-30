#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Created on Tue Jun 16 23:48:30 2020

@author: markampa
"""

import requests
import os
import pandas as pd
from datetime import datetime
import subprocess
from os import listdir
import re
import shutil

# timeit ?

obo_abbreviations_byte_estimates_file = \
    'obo_abbreviations_byte_estimates.csv'

non_obo_url_file = 'non_obo_urls.txt'

max_estimate = 10000000000

ART_PATH = '.'
TERMLIST_DIR = 'term_lists'
ONTO_DL_DIR = 'ontology_downloads'
EXTRACTION_OUPUT_DIR = 'extracts'

included_extensions = ['.owl.txt']

ROBOT_PATH = '/usr/local/bin/robot'

merge_output_file = 'merged_extracts.ttl'

turbo_UNmerged_ontology_file = 'turbo_unmerged.ttl'

turbo_with_extracts_ontology_file = 'turbo_with_extracts.ttl'

turbo_merged_ontology_file = 'turbo_merged.ttl'

turbo_reasoned_ontology_file = 'turbo_merged_inferred.ttl'

more_specimens_tsv_file = 'more-specimens.tsv'

more_specimens_ontology_url = \
    "https://raw.githubusercontent.com/" + \
    "PennTURBO/loinc_in_obo/master/more-specimens.ttl"

more_specimens_annotations_file = "more-specimens_annotations.ttl"

more_specimens_ontology_output_file = "more-specimens.ttl"

####

the_cwd = os.getcwd()

obo_abbreviations_byte_estimates = \
    pd.read_csv(obo_abbreviations_byte_estimates_file)

# for col in obo_abbreviations_byte_estimates.columns:
#     print(col)

smaller_obo_ontologies = \
    obo_abbreviations_byte_estimates[
        obo_abbreviations_byte_estimates.loc[:,
                                             'bytes_estimate']
        <= max_estimate]

obo_abbreviation_list = \
    smaller_obo_ontologies['obo_abbreviation'].tolist()

obo_url_prefix = 'http://purl.obolibrary.org/obo/'

for obo_abbreviation in obo_abbreviation_list:
    obo_file_name = obo_abbreviation + '.owl'
    obo_file_path = 'ontology_downloads/' + obo_file_name
    obo_url = obo_url_prefix + obo_file_name
    print(obo_abbreviation)

    # print(obo_file_name)
    # print(obo_file_path)
    # print(obo_url)

    now = datetime.now()
    current_time = now.strftime('%H:%M:%S')
    print('Current Time =', current_time)

    r = requests.get(obo_url, allow_redirects=True)
    open(obo_file_path, 'wb').write(r.content)

    # print("\n")

####

with open(non_obo_url_file) as my_file:
    non_obo_url_list = my_file.readlines()

for non_obo_url in non_obo_url_list:
    non_obo_url_stripped = non_obo_url.rstrip()
    print(non_obo_url_stripped)
    non_obo_file_name = re.sub('^.*/', '', non_obo_url_stripped)
    non_obo_file_path = 'ontology_downloads/' + non_obo_file_name
    print(non_obo_file_path)
    r = requests.get(non_obo_url_stripped, allow_redirects=True)
    open(non_obo_file_path, 'wb').write(r.content)

####

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

# '--individuals',
# 'include',
# '--annotate-with-source',
# 'true',

# for i in range(0, num_ontologies):
#     # print(i)
#     current_onto_abbrev = ontology_abbreviations[i]
#     current_onto_file = current_onto_abbrev + '.owl'
#     current_termlist_file = current_onto_abbrev + '.owl.txt'
#     current_extract_file = current_onto_abbrev + '.extract.ttl'
#     print(current_onto_file)
#     robot_array = [
#         ROBOT_PATH,
#         'extract',
#         '--method',
#         'STAR',
#         '--force',
#         'true',
#         '--verbose',
#         '--intermediates',
#         'minimal',
#         '--input',
#         os.path.join(ONTO_DL_PATH, current_onto_file),
#         '--term-file',
#         os.path.join(TERMLIST_PATH, current_termlist_file),
#         '--output',
#         os.path.join(EXTRACTION_OUPUT_PATH, current_extract_file),
#         ]
#     robot_call = subprocess.run(robot_array, stdout=subprocess.PIPE,
#                                 text=True, check=True)
#     print(robot_call.stdout)
#     # print(robot_call.stderr)

for i in range(0, num_ontologies):
    # print(i)
    current_onto_abbrev = ontology_abbreviations[i]
    current_onto_file = current_onto_abbrev + '.owl'
    current_termlist_file = current_onto_abbrev + '.owl.txt'
    current_extract_file = current_onto_abbrev + '.extract.ttl'
    print(current_onto_file)
    robot_array = [
        ROBOT_PATH,
        'extract',
        '--verbose',
        '--method',
        'MIREOT',
        '--force',
        'true',
        '--intermediates',
        'minimal',
        '--individuals',
        'definitions',
        '--imports',
        'exclude',
        '--input',
        os.path.join(ONTO_DL_PATH, current_onto_file),
        '--lower-terms',
        os.path.join(TERMLIST_PATH, current_termlist_file),
        '--output',
        os.path.join(EXTRACTION_OUPUT_PATH, current_extract_file),
        ]
    robot_call = subprocess.run(robot_array, stdout=subprocess.PIPE,
                                text=True, check=True)
    print(robot_call.stdout)
    # print(robot_call.stderr)

####

# pdro_merged_file = "pdro-merged.extract.ttl"
# pdro_merged_file_repaired = "pdro-merged-repaired.extract.ttl"
# pdro_merged_original_path = os.path.join(EXTRACTION_OUPUT_PATH, pdro_merged_file)
# pdro_merged_repaired_path = os.path.join(EXTRACTION_OUPUT_PATH, "repaired", pdro_merged_file)
# pdro_merged_stash_path = os.path.join(EXTRACTION_OUPUT_PATH, "original", pdro_merged_file)
# pdro_remove_survey_execution = [ROBOT_PATH, 'remove', '--input', pdro_merged_original_path, '--term', 'http://purl.obolibrary.org/obo/OMIABIS_0001035', '--output', pdro_merged_repaired_path]

# robot_call = subprocess.run(pdro_remove_survey_execution, stdout=subprocess.PIPE, text=True, check=True)
# print(robot_call.stdout)
# print(robot_call.stderr)

# shutil.move(pdro_merged_original_path, pdro_merged_stash_path)
# shutil.move(pdro_merged_repaired_path, pdro_merged_original_path)

####

extracts_merge_interleaved = [ROBOT_PATH, 'merge']

for i in range(0, num_ontologies):

    # print(i)

    current_onto_abbrev = ontology_abbreviations[i]
    current_extract_file = current_onto_abbrev + '.extract.ttl'
    current_extract_path = os.path.join(EXTRACTION_OUPUT_PATH,
                                        current_extract_file)
    print(current_extract_path)
    extracts_merge_interleaved.append('--input')
    extracts_merge_interleaved.append(current_extract_path)

extracts_merge_interleaved.append('--output')

merge_output_path = os.path.join(EXTRACTION_OUPUT_PATH,
                                 merge_output_file)

extracts_merge_interleaved.append(merge_output_path)

robot_call = subprocess.run(extracts_merge_interleaved,
                            stdout=subprocess.PIPE, text=True,
                            check=True)
print(robot_call.stdout)


####

turbo_UNmerged_ontology_path = os.path.join(ART_PATH,
                                            turbo_UNmerged_ontology_file)

turbo_with_extracts_ontology_path = \
    os.path.join(ART_PATH,
                 turbo_with_extracts_ontology_file)

next_merge_interleaved = [
    ROBOT_PATH,
    'merge',
    '--input',
    turbo_UNmerged_ontology_path,
    '--input',
    merge_output_path,
    '--output',
    turbo_with_extracts_ontology_path,
    ]

robot_call = subprocess.run(next_merge_interleaved,
                            stdout=subprocess.PIPE, text=True,
                            check=True)
print(robot_call.stdout)

####

more_specimens_tsv_path = os.path.join(ART_PATH,
                                       more_specimens_tsv_file)

more_specimens_annotations_path = \
    os.path.join(ART_PATH,
                 more_specimens_annotations_file)

more_specimens_ontology_output_path = \
    os.path.join(ART_PATH,
                 more_specimens_ontology_output_file)

template_specimens = [
    ROBOT_PATH,
    'template',
    '--template',
    more_specimens_tsv_path,
    '--ontology-iri',
    more_specimens_ontology_url,
    '--input',
    turbo_with_extracts_ontology_path,
    '--ancestors',
    'annotate',
    '--annotation-file',
    more_specimens_annotations_path,
    '--output',
    more_specimens_ontology_output_path]

robot_call = subprocess.run(template_specimens,
                            stdout=subprocess.PIPE, text=True,
                            check=True)
print(robot_call.stdout)

####

turbo_merged_ontology_path = \
    os.path.join(ART_PATH, turbo_merged_ontology_file)

last_merge_interleaved = [
    ROBOT_PATH,
    'merge',
    '--input',
    turbo_with_extracts_ontology_path,
    '--input',
    more_specimens_ontology_output_path,
    '--output',
    turbo_merged_ontology_path,
    ]

robot_call = subprocess.run(last_merge_interleaved,
                            stdout=subprocess.PIPE, text=True,
                            check=True)
print(robot_call.stdout)

####

turbo_reasoned_ontology_path = \
    os.path.join(ART_PATH,
                 turbo_reasoned_ontology_file)

reasoning = [
    ROBOT_PATH,
    'reason',
    '--reasoner',
    'hermit',
    '--create-new-ontology-with-annotations',
    'true',
    '--equivalent-classes-allowed',
    'all',
    '--axiom-generators',
    '"SubClass EquivalentClass"',
    '--input',
    turbo_merged_ontology_path,
    '--output',
    turbo_reasoned_ontology_path
    ]

robot_call = subprocess.run(reasoning,
                            stdout=subprocess.PIPE, text=True,
                            check=True)
print(robot_call.stdout)

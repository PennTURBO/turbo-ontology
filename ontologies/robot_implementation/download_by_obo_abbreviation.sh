# as is, this reads the abbreviations from a hardcoded file
# and will write the downloaded files
# to the CWD
# and trust the source's filename

# rm *.owl

# export destpath='/Users/markampa/ontology_downloads/'
export abbrevsource='/Users/markampa/Turbo-Ontology/ontologies/animals_robot_transition/obo_abbreviations_for_curl.txt'

while read -r oboabbreviation ;
  do \
  # echo $oboabbreviation ;
  obofile=${oboabbreviation}.owl ;
  obopurl='http://purl.obolibrary.org/obo/'${obofile} ;
  # echo $obopurl ;
  # -v
  command="curl -J -O -L ${obopurl}" ;
  echo $command ;
  ${command} ;
  done < ${abbrevsource}

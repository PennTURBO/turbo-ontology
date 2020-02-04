#!/bin/bash
output="$1"
shift
for file
do
  inputs+=( --input "$file" )
done

echo "parameters"
echo $output
echo "${inputs[@]}"

echo "running"

/C/Program\ Files/Java/jdk1.8.0_201/bin/java -Xms4G -Xmx8G -jar ~/robot.jar merge -v "${inputs[@]}" --output "$output"

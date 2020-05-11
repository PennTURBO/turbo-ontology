#!/bin/bash
output="$1"
shift
for file in *.ttl
do
  inputs+=( --input "$file" )
done

# robot_java_path='/C/Program\ Files/Java/jdk1.8.0_201/bin/java /C/Program\ Files/Java/jdk1.8.0_201/bin/java -Xms4G -Xmx8G -jar ~/robot.jar'

echo "parameters"
echo $output
echo "${inputs[@]}"

echo "running"

robot merge -v "${inputs[@]}" --output "$output"

#!/bin/bash

if [[ ! -e "${1}" ]]
 then
   echo 'The files does not exist.' >&2
   exit 1
fi

echo 'Count, IP, Location'
grep Failed ${1} | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | while read COUNT IP
do
if [[ "${COUNT}" -gt 10 ]]
then
  LOCATION=$(geoiplookup ${IP} | awk -F ',' '{print $2}')
  echo "${COUNT}, ${IP}, {LOCATION}"
fi
done
exit 0

# Alternative
IPS_COUNTED=$(grep Failed ${1} | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr)

while read COUNT IP
do
 ...
done < IPS_COUNTED
  





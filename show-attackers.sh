#!/bin/bash

if [[ ! -e "${1}" ]]
 then
   echo 'The files does not exist.' >&2
   exit 1
fi

echo 'Count, IP, Location'
IPS_COUNTED=grep Failed ${1} | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr
while read COUNT IP
do
if [[ "${COUNT}" -gt 10 ]]
then
  LOCATION=$(geoiplookup ${IP} | awk -F ',' '{print $2}')
  echo "${COUNT}, ${IP}, {LOCATION}"
fi
done <<< "${IP_COUNTED}"
exit 0
  





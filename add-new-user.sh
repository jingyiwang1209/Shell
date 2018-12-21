#!/bin/bash

if [[ "${UID}" -ne 0 ]]
then
  echo 'Please use sudo or root' >&2
  exit 1
fi

if [[ "${#}" -lt 1 ]]
then
  echo "Please provide at least one argument." >&2
  exit 1
fi

USERNAME="${1}"
shift 1

COMMENT="${@}"

# Create a user name
if [[ ! -z "${COMMENT}" ]]
then
  useradd -m ${USERNAME} -c "${COMMENT}" &> /dev/null
else
   echo "Please also provide a commment."
fi


if [[ "${?}" -ne 0 ]]
then
  echo "Cannot create the user name." >&2
  exit 1
fi

PASSWORD="$(date +%s%N | sha256sum | head -c42)"
echo "${PASSWORD}" | passwd --stdin ${USERNAME} &> /dev/null

if [[ "${?}" -ne 0 ]]
then
  echo "Cannot create the password." >&2
  exit 1
fi

# Force password change on first login.
passwd -e ${USERNAME} &> /dev/null

echo "${USERNAME}, ${PASSWORD}, ${HOSTNAME}"
exit 0
 
  


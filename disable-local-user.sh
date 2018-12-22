#!/bin/bash 

ARCHIVE_DIR='/archive'

usage(){
  # Display the usage and exit
  echo "Usage: ${0} [-dra] USER [USERN]..." >&2
  echo 'Disable a local Linux account.' >&2
  echo ' -d Deletes accounts instead of disabling them.'
  echo ' -r Removes the home directory associated with the account(s).' >&2
  echo ' -a Creates an archive of the home directory associated with the account(s).' >&2
}


if [[ "${UID}" -ne 0 ]]
then
  echo "Please run with sudo or as root" >&2
  exit 1
fi

if [[ "${#}" -eq 0 ]]
then
  echo "Please provide your username" >&2
  exit 1
fi

# Parse the options
while getopts dra OPTION
do
   case ${OPTION} in
      d)
        DELETE_USER='true' 
        ;;
      r)
        REMOVE_OPTION='-r'
        ;;
      a)
        ARCHIVE='true'
        ;;
      ?)
        usage
        ;;
      esac
done

# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"

# If the user does not supply at least one argument,give them help.
if [[ "${?}" -lt 1 ]]
then
  usage
fi

# Loop through all the usernames supplied as arguments.
for USERNAME in "${@}"
do
  echo "Processing user: ${USERNAME}"
  # Make sure the UID of the account is at least 1000.
  USERID=$(id -u ${USERNAME})
  if [[ "${USERID}" -lt 1000 ]]
  then
    echo "Refusing to remove the ${USERNAME} account with UID ${USERID}"
    exit 1
  fi
  
  # Create an archive if requested to do so.
  if [[ "${ARCHIVE}" = 'true' ]]
  then
    # Make sure the ARCHIVE_DIR directory exists.
    if [[ ! -d "${ARCHIVE_DIR}" ]]
    then
      echo "Creating ${ARCHIVE_DIR} directory."
      mkdir -p ${ARCHIVE_DIR}
      if [[ "${?}" -ne 0 ]]
      then
        echo 'The archive directory ${ARCHIVE_DIR} could not be created.' >&2
        exit 1
      fi
    fi
      
    # Archive the user's home directory and move it into the ARCHIVE_DIR.
    HOME_DIR="./home/${USERNAME}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tar.gz"
    if [[ -d "${HOME_DIR}" ]]
    then
      echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
      tar -zcf ${ARCHIVE_FILE} ${HOME_DIR}  &> /dev/null
      if [[ "${?}" -ne 0 ]]
       then
        echo "Could not create ${ARCHIVE_FILE}." >&2
        exit 1
     else
       echo "${HOME_DIR} does not exist or is not a directory."
       exit 1
     fi
   fi
    

   if [[ "${DELETE_USER}" = 'true' ]]
     then
       usedel ${REMOVE_OPTION} ${USERNAME}
       if [[ "${?}" -ne 0 ]]
       then
         echo "The account ${USERNAME} was not deleted." >&2
         exit 1
       fi
       echo "The account ${USERNAME} was deleted."
   else
      chage -E 0 ${USERNAME}
      # Then the same like above
  fi
 fi
done

exit 0 
      

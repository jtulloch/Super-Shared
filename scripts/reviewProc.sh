#!/bin/bash

# Fail on uninitialized variable
set -u
# Exit on any command error including intermediate failures normally trapped by pipe
set -e
set -o pipefail

usage () {
    script_name=`basename $0`
    echo "Usage: ${script_name} proc_file_prefix [new_version]"
    echo -e "\t If \$PROJECT_PATH is set then it will be used, otherwise it will use the current directory"
}

if [ $# != 2 ]
then
    usage
    exit 1
fi

prefix=$1
revision=$2
previous_revision=$(($revision-1))

PROJECT_PATH=${PROJECT_PATH:-"."}
if [ "$PROJECT_PATH" == "." ]; then
    base_file_path="${prefix}"
else
    base_file_path="${PROJECT_PATH}/app/installers/storedProcedures/${prefix}"
fi

vimdiff ${base_file_path}.${previous_revision}.sql ${base_file_path}.${revision}.sql

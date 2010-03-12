#!/bin/bash

lines=`svn up`

IFS='
'
for line in $lines
do
    echo $line
    conflict=`echo $line |grep "^C"`
    if [ "$conflict" != "" ];
    then
        CONFLICTS=1
    fi
done

install=`echo $lines |grep "installer"`
if [ "${install}" != "" ]; then
    echo "*********************************"
    echo "*                               *"
    echo "*    INSTALLER FILE CHANGED     *"
    echo "*                               *"
    echo "*********************************"
fi

if [ $CONFLICTS ];
then
    echo
    echo "***********************************"
    echo "*                                 *"
    echo "*    There were conflicts.        *"
    echo "*                                 *"
    echo "***********************************"
    echo
fi

exit 0

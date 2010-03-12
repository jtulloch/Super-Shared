#!/bin/bash

startPath=`pwd`

if [ -d akelos ]; then
    return 0
fi

currentPath=`pwd`

while [ $currentPath != "/" ] && [ ! -d akelos ]
do
    cd ..
    currentPath=`pwd`
done

if [ ! -d akelos ]; then
    cd $startPath
    return 1
fi

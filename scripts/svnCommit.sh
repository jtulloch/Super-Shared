#!/usr/bin/zsh

svnstatus() {
    svn status | grep -v 'app/installer/versions' |grep -v 'compiled' |grep -v 'tmp/sess' |grep -v 'tmp/installer_versions' | grep -v 'tmp/views' |grep -v 'css-cacheer' |grep -v 'fixtures/app/views' |grep -v 'fixtures/app/helpers' |grep -v 'checkWidget' |grep -v 'locale' |grep -v 'environment' |grep -v 'input.txt' |grep -v 'output.txt' |grep -v 'javascripts/release'
}

getInput() {
    echo $1
    read ANSWER;

    if [ "${ANSWER}" = "q" ]; then
        echo 
        echo Aborting commit
        echo 
        exit 0
    fi

    if [ "${ANSWER}" = "r" ]; then
        echo Reverting!
        svn revert ${FILENAME}
    fi

}

ORIGINALIFS=${IFS}
IFS='
'
COMMITFILES=""
ADDFILES=""
getInput "Update? (y/n/q)";
if [ "${ANSWER}" = "y" ]; then
    ${SHAREDPATH}/scripts/svnupdate.sh
fi
ANSWER=0

for i in `svnstatus`
do
    FOO=`echo $i | sed "s/+//g"`
    STATUS=${i%% *}
    FILENAME=${i##$STATUS       }
    #FILENAME=`echo $FILENAME | sed "s/A  +   //g"`

    ANSWER=0

    if [ "${STATUS}" = "?" ]; then
        getInput "Add ${FILENAME}? (y/n/q/x)";
        if [ "${ANSWER}" = "y" ]; then
            svn add ${FILENAME}
            STATUS=A
        fi
        if [ "${ANSWER}" = "x" ]; then
            echo Deleting!
            rm -f ${FILENAME}
        fi
        ANSWER=0
    fi

    if [ "${STATUS}" = "M" ] || [ "${STATUS}" = "A" ]; then
        while [ "${ANSWER}" = "0" ]; do
            TODOCHECK=`svn diff ${FILENAME} | grep -i "XXX\|TODO\|debug\|wtf\|dumpObject" | egrep -v "^-"`

            if [ "${#TODOCHECK}" != "0" ]; then
                echo
                echo There are possible todos/debug statements remaining in your code:
                echo ${TODOCHECK}
                echo
            fi
            getInput "Commit ${FILENAME}? (r/d/y/n/q)";

            if [ "${ANSWER}" = "d" ]; then
                svn diff --diff-cmd ${SHAREDPATH}/scripts/vimdiff-svn-wrapper.sh ${FILENAME}
                echo
                echo "******"
                echo "* Checking file again..."
                echo "******"
                echo
                ANSWER="0"
            fi
        done
    fi

    if [ "${STATUS}" = "D" ]; then
        getInput "Commit deleted file ${FILENAME}? (y/n/q)";
    fi

    if [ "${ANSWER}" = "y" ]; then
        COMMITFILES=(${FILENAME} ${COMMITFILES})
    fi
done

if [ "${#COMMITFILES}" = "0" ]; then
    echo "There are no files to commit"
    exit 0;
fi

echo
echo "************************************"
echo "   Commit files is:"
echo "      ${COMMITFILES}"
echo "************************************"
echo
echo "Check in these items? (y/n)"
read ANSWER;
if [ "${ANSWER}" = "y" ]; then
    svn ci ${COMMITFILES}
fi

exit 0


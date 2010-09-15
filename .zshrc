_CHANGE_PROMPT=0
if [ -f $HOME/.curverc ]; then
    source $HOME/.curverc
fi

if [ "${SHAREDPATH}" = "" ]; then
    SHAREDPATH=/home/shared
fi

alias jssnip='sh ${SHAREDPATH}/snippets.sh javascript_snippets'
alias phpsnip='sh ${SHAREDPATH}/snippets.sh php_snippets'

#
# Hero Aliases
#
alias listA='cat ~/.zshrc |grep alias && cat ${SHAREDPATH}/.zshrc |grep alias'
alias zrc='vi ~/.zshrc && source ~/.zshrc'
alias zrcs='sudo vi ${SHAREDPATH}/.zshrc && source ~/.zshrc'
alias svnvimdiff="svn diff --diff-cmd ${SHAREDPATH}/scripts/vimdiff-svn-wrapper.sh"
alias svnconflict='svn st | egrep "^C"'
alias svnUp='${SHAREDPATH}/scripts/svnupdate.sh'
alias svncommit='${SHAREDPATH}/scripts/svnCommit.sh'
alias taillog='tail -F ~/public_html/*/log/*.log'
alias cleanlog='echo -n > ~/public_html/*/log/*'
alias hero='cd $CURVESPACE/$CURVEPROJECT'
alias root='. ${SHAREDPATH}/gotoProjectRoot.sh || hero'
alias gotoHeroPath='root && cd' # Shortcut for other aliases to use.  Not really intended to be used by humans but could be.
alias app='gotoHeroPath app'
alias contr='gotoHeroPath app/controllers'
alias model='gotoHeroPath app/models'
alias claim='gotoHeroPath app/lib/claim'
alias conv='gotoHeroPath app/lib/conversion/lib'
alias smile='gotoHeroPath app/lib/reminder'
alias views='gotoHeroPath app/views'
alias inst='gotoHeroPath app/installers'
alias procs='gotoHeroPath app/installers/storedProcedures'
alias public='gotoHeroPath public'
alias script='gotoHeroPath public/javascripts'
alias widget='gotoHeroPath public/javascripts/curve'
alias doc='gotoHeroPath public/javascripts/curve/doc/pages'
alias style='gotoHeroPath public/stylesheets/curve'
alias dojo='gotoHeroPath public/javascripts/dojo/'
alias dijit='gotoHeroPath public/javascripts/dijit/'
alias dojox='gotoHeroPath public/javascripts/dojox/'
alias ak='gotoHeroPath akelos/lib/'
alias func='gotoHeroPath test/functional/controllers/'
alias unit='gotoHeroPath test/unit/app/'
alias tstfunc='root && ./script/test test/functional'
alias tstunit='root && ./script/test test/unit'
alias tstall='root && ./script/test test/unit && ./script/test test/functional'
alias tdata='gotoHeroPath test/fixtures/app/installers/data'

alias db='psql -U $(getCurrentDatabaseName) -h ${CURVE_POSTGRES_SERVER} $(getCurrentDatabaseName)'

alias testdb='psql -h ${CURVE_POSTGRES_SERVER} test_$(getCurrentDatabaseName)'

alias cleandb='root && psql -h ${CURVE_POSTGRES_SERVER} -f ${CURVEPROJECT}_dump.sql $CURVEPROJECT'
alias dumpdb='root && pg_dump -h ${CURVE_POSTGRES_SERVER} --clean -U $(getCurrentDatabaseName) -f $(getCurrentDatabaseName)_dump.sql $(getCurrentDatabaseName)'

alias loadtestdata='root && dropdb -h ${CURVE_POSTGRES_SERVER} $(getCurrentDatabaseName) && createdb -h ${CURVE_POSTGRES_SERVER} -O $(getCurrentDatabaseName) $(getCurrentDatabaseName) && psql -h ${CURVE_POSTGRES_SERVER} $(getCurrentDatabaseName) -f app/installers/data/default_test_data.sql && cd -'
alias dumptestdata='root && pg_dump -O $(getCurrentDatabaseName) > app/installers/data/default_test_data.sql && cd -'
alias setadmin='db -f ${SHAREDPATH}/scripts/setAdminUser.sql'

alias riptheheartoutofmyfuckingdatabasebecauseidontneeditanymore='dropdb -h ${CURVE_POSTGRES_SERVER} $(getCurrentDatabaseName)'
alias cdb='createdb -h ${CURVE_POSTGRES_SERVER} -O $(getCurrentDatabaseName) $(getCurrentDatabaseName)'
alias cdbuser='createuser -h ${CURVE_POSTGRES_SERVER} $(getCurrentDatabaseName)'

getCurrentDatabaseName() {
    php ${SHAREDPATH}/scripts/getCurrentDatabaseName.php
}

getCurrentHeroName() {
    php ${SHAREDPATH}/scripts/getCurrentHeroName.php
}

cleandatabase() {
    local FILE_NAME=$1
    local SQL_DUMP_FILE
    if [ $# -eq 0 ]; then
        BRANCHED_DUMP_NAME=$(getCurrentDatabaseName)_dump.sql

        if [ -f ${BRANCHED_DUMP_NAME} ]; then
            SQL_DUMP_FILE=${BRANCHED_DUMP_NAME}
        else
            SQL_DUMP_FILE=${CURVEPROJECT}_dump.sql
        fi
    else
        FULL_FILE_PATH=`readlink -f ${FILE_NAME}`
        if [ -f "$FULL_FILE_PATH" ]; then
            local SQL_DUMP_FILE=$FULL_FILE_PATH
        else
            return
        fi
    fi

    root
    riptheheartoutofmyfuckingdatabasebecauseidontneeditanymore
    cdb

    CURRENT_DATABASE=$(getCurrentDatabaseName)

    echo "Cleaning database ${CURRENT_DATABASE} with [${SQL_DUMP_FILE}]."

    psql -h ${CURVE_POSTGRES_SERVER} -U ${CURRENT_DATABASE} -f ${SQL_DUMP_FILE} ${CURRENT_DATABASE}
    echo "Renaming schema..."
    NAME=`cat ${SQL_DUMP_FILE} |ack-grep -i "CREATE SCHEMA"|grep -v public`
    RENAME_SCHEMA=`echo ${NAME} |sed 's/CREATE SCHEMA //g' |sed 's/;//g'`
    echo "Found name [${RENAME_SCHEMA}]"
    HERONAME=$(getCurrentHeroName)

    if [ "${RENAME_SCHEMA}" != "${HERONAME}" ]; then
        echo "Renaming schema from [${RENAME_SCHEMA}] to [${HERONAME}]..."
        db -c "ALTER SCHEMA ${RENAME_SCHEMA} RENAME TO ${HERONAME}"
    fi
}

dumpdatabase() {
    root
    pg_dump -h ${CURVE_POSTGRES_SERVER} -U $(getCurrentDatabaseName) -f $(getCurrentDatabaseName)_dump.sql $(getCurrentDatabaseName)
}


runtest() {
    local testCommand
    local testArg
    testCommand='./script/test'
    testArg=()

    if [ -z $1 ]; then
        echo "No file specified"
    else
        secondLastArg=''
        lastArg=''
        for arg in $@
        do
            testArg+="${secondLastArg}"
            secondLastArg="${lastArg}"
            lastArg="${arg}"
        done

        testPath='test/'
        case ${secondLastArg} in
        "-f"*)
            testPath+='functional'

            if [ "${lastArg}" != "all" ]; then
                testPath+="/controllers/"
            fi
        ;;
        "-m"*)
            testPath+='unit'

            if [ "${lastArg}" != "all" ]; then
                testPath+="/app/models/"
            fi
        ;;
        "-u"*)
            testPath+='unit/us/'
        ;;
        "-l"*)
            testPath+='unit/app/lib/'
        ;;
        "-ak"*)
            testPath+='unit/akelos/'
        ;;
        esac

        if [ "${lastArg}" != "all" ]; then
            testPath+="${lastArg}"
        fi

        testArg+=${testPath}

        cd ${CURVESPACE}/${CURVEPROJECT} && ${testCommand} ${testArg}
    fi
}

proj () {
    if [ -z $1 ]; then
        selectProject
    else
        export CURVEPROJECT=$1
        hero
    fi
}

projview () {
    cd ${CURVESPACE}/${1}
}

clearProject() {
    export CURVEPROJECT=''
    setprompt
}

selectProject() {
    CURVEPROJECTS=()
    PROJCOUNT=1

#This is to make the for loop parse by new lines instead of whitespace
IFS_BAK=$IFS
IFS="
"

    echo "0) None"

    for PROJ in `listHeroes.sh`
    do
        CURVEPROJECTS+=($PROJ)
        echo "${PROJCOUNT}) ${PROJ}"
        PROJCOUNT=$(( $PROJCOUNT + 1 ))
    done
IFS=$IFS_BAK
IFS_BAK=

    read ANSWER;
    if [ "${ANSWER}" = "" ]; then
        CURVEPROJECT=""
        export CURVEPROJECT
        cd
    elif [ "${ANSWER}" != "0" ]; then
        proj ${CURVEPROJECTS[$ANSWER]%% *}
    else
        CURVEPROJECT=""
        export CURVEPROJECT
        cd
    fi
}

#
# Prompt
#
autoload colors; colors

for COLOR in RED GREEN BLUE YELLOW WHITE BLACK CYAN MAGENTA; do
    eval PR_$COLOR='%{$fg[${(L)COLOR}]%}'
    eval PR_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done
PR_RESET="%{${reset_color}%}";
RPROMPT='%~/'

getCurrentBranch() {
    git branch 2> /dev/null | grep --color=never -e '\* ' | sed 's/^..\(.*\)/\1/'
}

precmd() {
    if [ ${_CHANGE_PROMPT} = 1 ]; then
        setprompt
    fi  
    _CHANGE_PROMPT=0
}   

chpwd() {
    _CHANGE_PROMPT=1
}

preexec() {
    case "$1" in
    "git co"*)
        _CHANGE_PROMPT=1
    ;;  
    "git checkout"*)
        _CHANGE_PROMPT=1
    ;;  
    esac
}   

setprompt() {
    if [ "${CURVEPROJECT}" = "" ]; then
        PROMPT="${PR_BLUE}$HOST${PR_RESET}${PR_YELLOW}->${PR_RESET}"
    else
        CURRENTPATH=`pwd`
        case $CURRENTPATH in
        ${CURVESPACE}/${CURVEPROJECT}*)
            PROMPT="${PR_BLUE}$HOST${PR_RESET}${PR_YELLOW} - ${PR_RESET}${PR_GREEN}$CURVEPROJECT${PR_RESET}${PR_YELLOW}->${PR_RESET}"
        ;;
        ${CURVESPACE}/*)
            PROMPT="${PR_BLUE}$HOST${PR_RESET}${PR_YELLOW} - ${PR_RESET}${PR_RED}$CURVEPROJECT${PR_RESET}${PR_YELLOW}->${PR_RESET}"
        ;;
        *)
            PROMPT="${PR_BLUE}$HOST${PR_RESET}${PR_YELLOW} - ${PR_RESET}${PR_RED}$CURVEPROJECT${PR_RESET}${PR_YELLOW}->${PR_RESET}"
        ;;
        esac
    fi
}

RPROMPT='%~/'
setprompt

blame() {
    svn blame -v $1 | awk '{$3=$2;$2=$1;$1=NR;$4=$5=$6=$7=$8=$9="";gsub(FS "+","\t")}1'
}

commitCheck () {
    svn diff | grep -i "XXX\|TODO\|debug\|wtf\|dumpObject" | egrep -v "^-"
}

SHAREDFOLDER=${SHAREDPATH}
fpath=(${SHAREDFOLDER}/.fun $fpath)
compinit


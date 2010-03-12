alias jssnip='sh /home/shared/snippets.sh javascript_snippets'
alias phpsnip='sh /home/shared/snippets.sh php_snippets'

if [ -f $HOME/.curverc ]; then
    source $HOME/.curverc
fi

runtest() {
    local testCommand
    local testArg
    testCommand='./script/test'
    testArg='test/'

    if [ -z $1 ]; then
        echo "No file specified"
    else
        case $1 in
        "-f"*)
            testArg+='functional'

            if [ "${2}" != "all" ]; then
                testArg+="/controllers/"
            fi
        ;;
        "-m"*)
            testArg+='unit'

            if [ "${2}" != "all" ]; then
                testArg+="/app/models/"
            fi
        ;;
        "-u"*)
            testArg+='unit/us/'
        ;;
        "-l"*)
            testArg+='unit/app/lib/'
        ;;
        esac

        if [ "${2}" != "all" ]; then
            testArg+="${2}"
        fi

        cd ${CURVESPACE}/${CURVEPROJECT} && ${testCommand} ${testArg}
    fi
}


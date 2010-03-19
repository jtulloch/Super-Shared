#!/bin/sh
if [ $# -ne 1 ]; then
    echo "USAGE: installEnv.sh [install|init|update]";
    exit 1
fi

SHARED=${HOME}/shared
PROJNAME=Super-Shared
GITURL=git@github.com:dalefukami/Super-Shared.git

if [ "${1}" = "install" ]; then
    echo "Installing...\n"
    if [ ! -d "${SHARED}" ]; then
        echo "Creating shared folder [${SHARED}]...\n";
        mkdir ${SHARED}
    fi

    CURRDIR=`pwd`
    cd ${SHARED}

    if [ -d "${SHARED}/${PROJNAME}" ]; then
        echo "[${PROJNAME}] already exists in [${SHARED}]...overwrite? [y/n]"
        read ANSWER
        if [ "${ANSWER}" = "y" ]; then
            rm -rf ${SHARED}/${PROJNAME}
            echo "remove\n"
        else
            echo "Cannot do anything more...exiting"
            exit 1
        fi
    fi
    echo "Checking out shared env...[${GITURL}]"
    git clone ${GITURL} 

    cd ${CURRDIR}
elif [ "$1" = "init" ]; then
    echo "source ${SHARED}/${PROJNAME}/.zshrc" > ${HOME}/temp.zsh
    cat ${HOME}/.zshrc >> ${HOME}/temp.zsh
    mv ${HOME}/temp.zsh ${HOME}/.zshrc

    echo "source ${SHARED}/${PROJNAME}/.vimrc" > ${HOME}/temp.zsh
    cat ${HOME}/.vimrc >> ${HOME}/temp.zsh
    mv ${HOME}/temp.zsh ${HOME}/.vimrc

    if [ -f ${HOME}/.curverc ]; then
        echo "adding\n"
        echo "SHAREDPATH=${SHARED}/${PROJNAME} && export SHAREDPATH" >> ${HOME}/.curverc
    fi

    if [ -d ${HOME}/.vim ]; then
        echo "vim directory exists, overwrite [y/n]"
        read ANSWER

        if [ "${ANSWER}" = "y" ];then
            mv ${HOME}/.vim ${HOME}/.vim_back
            ln -s ${SHARED}/${PROJNAME}/.vim ${HOME}/.vim
        fi
    else
        ln -s ${SHARED}/${PROJNAME}/.vim ${HOME}/.vim
    fi

elif [ "$1" = "update" ]; then
    echo "Updating...[$PROJNAME] from [${GITURL}]...\n"
    CURRDIR=`pwd`
    cd ${SHARED}/${PROJNAME}
    git pull origin master
    cd ${CURRDIR}
else
    echo "USAGE: installEnv.sh [install|init|update]";
    exit 1
fi


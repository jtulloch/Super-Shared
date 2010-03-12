#!/bin/sh

SNIPPET='/home/shared/snippets'
SHARED_PATH='/home/shared/'
EMAIL_USERS="${SHARED_PATH}/email/emails.cfg"
EMAIL_FILE="${SHARED_PATH}/email/mailMessage.email"

if [ $# -eq 1 ]; then
    TARGET=${1}
else
    echo "USAGE: sh snippets.sh [filename] "
    exit 1
fi

/usr/bin/vim ${SNIPPET}/${TARGET}.vim
rm ${EMAIL_FILE}
/usr/bin/vim ${EMAIL_FILE}

echo "Would you like to send email ${ME}? (y or n)"
read ANSWER

if [ "${ANSWER}" = "y" ]; then
for i in `cat ${EMAIL_USERS}` 
        do
            echo "Sending email to ${i}"
            MAIL=`mail -s "${TARGET} updated" ${i} < ${EMAIL_FILE}`
        done
fi

exit 0

#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

. /root/.duplicity.pwd

GPGKEYID=""
EXCLUDESTR="--exclude /usr/ports/ --exclude /proc/ --exclude /dev/ --exclude /mnt/ --exclude /tmp --exclude /usr/compat/linux/proc"
MAILSERVER="localhost"
MAILTODOMAIN=""
MAILTORCPT=""
WEBDAVUNAME=""
WEBDAVHOST=""
WEBDAVPORT=""
WEBDAVURI=""

sendMail() {
  {
    echo "ehlo $MAILTODOMAIN"
    sleep 1
    echo "mail from:hostmaster@$MAILTODOMAIN"
    sleep 1
    echo "rcpt to:$MAILTORCPT@$MAILTODOMAIN"
    sleep 1
    echo "data"
    sleep 1
    echo "Subject:$1 Backup (`hostname -f`) Completed"
    sleep 1
    echo "From:hostmaster@$MAILTODOMAIN"
    sleep 1
    echo "X-Backup-Action: $1"
    sleep 1
    echo "X-Backup-Host: `hostname -f`"
    sleep 1
    echo "X-Backup-Type: System

    $2
."
    sleep 1
    echo "quit"
  } | telnet $MAILSERVER 25

}

fullBackup() {
  RESULT=$(/usr/local/bin/duplicity full --encrypt-key $GPGKEYID $EXCLUDESTR --ssl-cacert-file /usr/local/etc/ssl/cert.pem  --num-retries 1 --volsize 10 / webdavs://$WEBDAVUNAME:"$WEBDAVPWD"@$WEBDAVHOST:$WEBDAVPORT/$WEBDAVURI 2>/tmp/backup.stderr)
  stderr=`cat /tmp/backup.stderr`
  RESULT="$stderr "$'\n'"$RESULT"
  # Remove all but last four full backups
  tmp=$(/usr/local/bin/duplicity remove-all-but-n-full 4 --force webdavs://$WEBDAVUNAME:'"$WEBDAVPWD"'@$WEBDAVHOST:$WEBDAVPORT/$WEBDAVURI --ssl-cacert-file /usr/local/etc/ssl/cert.pem  --num-retries 1 2>/tmp/backup.stderr)
  stderr=`cat /tmp/backup.stderr`
  tmp="$stderr "$'\n'"$tmp"
  RESULT="$RESULT"$'\n'"$tmp"
  TYPE="Full"
  sendMail $TYPE "$RESULT"
}

incrementalBackup() {
  RESULT=$(/usr/bin/env /usr/local/bin/duplicity --encrypt-key $GPGKEYID $EXCLUDESTR / webdavs://$WEBDAVUNAME:"$WEBDAVPWD"@$WEBDAVHOST:$WEBDAVPORT/$WEBDAVURI --ssl-cacert-file /usr/local/etc/ssl/cert.pem  --num-retries 1 --volsize 10 2>/tmp/backup.stderr)
  stderr=`cat /tmp/backup.stderr`
  RESULT="$stderr "$'\n'"$RESULT"
  sendMail $TYPE "$RESULT"
}

while getopts ":hfi" opt; do
    case "$opt" in
    f)  TYPE="Full"
        fullBackup
        ;;
    i)  TYPE="Incremental"
        incrementalBackup
        ;;
    esac
done

exit 1

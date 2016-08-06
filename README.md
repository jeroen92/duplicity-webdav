# duplicity-webdav
Simple script which performs an encrypted backup of the root FS using duplicity and GPG. The backup is then uploaded to a WebDAV(S) server. Can be used to perform either an incremental or full backup. Sends an email upon completion. 

#### Backup and recovery has been tested with:
* FreeBSD 10.2 RELEASE
* gpg 1.4.20 and 2.1.11
* duplicity 0.7.06 and 0.7.07.1
* stackstorage.com for WebDAV endpoint

#### How to use
Use *-f* flag for a full backup, and *-i* for incremental. That's all there is to it.

#### Get it into production
1. Make sure you've installed duplicity and gpg. Note that when using GPG > 2.0, you'll need "pinentry-mode loopback" in your *.gnupg/gpg.conf*.
2. Create/import a GPG keypair dedicated for backups.
3. Store your WebDAV user's password in */root/duplicity.pwd*

    ```
    WEBDAVPWD=""
    ```
4. Change ownership of above .pwd file to root:wheel, and set file permissions to 500.
5. Copy backup.sh to */usr/local/bin/backup*. Adjust it to your needs and make sure to fill in all $VARS.
6. Test. Test. Test.
7. Add a cronjob. The example below performs a daily incremental backup and a weekly full backup.

    ```
    0 23 * * * /usr/local/bin/backup -i
    0 8 * * 6 /usr/local/bin/backup -f
    ```

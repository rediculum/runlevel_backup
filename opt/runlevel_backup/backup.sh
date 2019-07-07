#!/bin/bash
#
# RUNLEVEL.CH BACKUP SCRIPT
#
# Usage: backup.sh [-n]
#
# Fri Jul  7 16:55:21 CEST 2006 / Added MySQL Stop-Start-Check
# Mon Oct 15 18:20:48 CEST 2007 / Added exit code if HD couldn't be mounted
# Tue Dec 11 23:02:18 CET 2007 / Added /usr/local/sbin to backup and -p para to cp command
# Tue May  6 10:02:57 CEST 2008 / Added new procedure: mount backup-disk before backup and umount after
# Wed May 21 09:59:15 CEST 2008 / Personalized for Server
# Tue Jul  8 10:54:20 CEST 2008 / Changed cp command to rsync. Added for loop for folders to be backed
#                                 Added combo backup for nas and server with uname check
#                                 Not umount anymore
# Mon Nov 24 13:22:06 CET 2008 / Added mybook mirroring
# Thu Feb  5 22:20:49 CET 2009 / Modifed for only 1 server
# Tue Feb 24 14:13:59 CET 2009 / Removed mybook mirroring. Is now on mybook_sync.sh
# Fri Sep  4 16:46:37 CET 2009 / Added /var/lib/ldap to FOLDERS
# Wed Feb 24 09:51:17 CET 2010 / Optimized complete code with funcs and printf
# Wed Aug 18 14:01:22 CET 2010 / Changed rsync to rdiff-backup for incremental backup
# Fri Dec  3 10:16:07 CET 2010 / Added retention for increments
#                                Include library for common variables and functions
# Fri Aug 19 18:20:56 CET 2011 / Added package list file into /root
# Tue May  7 16:40:14 CEST 2013 / Changed Database (MySQL/PG/LDAP) backup to dumps
# Fri Apr  5 13:23:20 CEST 2019 / Redesigned by customizable config file
# Sun Jul  7 20:11:49 CEST 2019 / Add Raspbian to Distro and refine grep


### Config
TIMESTART=`date +%s`
BASEDIR=`dirname $0`

# Source config
. $BASEDIR/backup.conf || { echo "backup.conf not found"; exit 1; }
# Source library
. $BASEDIR/backup.lib || { echo "backup.lib not found"; exit 1; }

### Checks
if [ "$1" == "-n" ]; then
	DRYRUN=1
	RDIFFPARAMS="--compare"
	echo "RUNNING IN DRY MODE"
fi

# Check if rdiff-backup exists
[[ `which $RDIFFBIN` ]] || { echo "$RDIFFBIN not found"; exit 1; }

# Check if a keychain with an adequate ssh agent exist and load it
f_keychain

# Check if remote server is reachable and backup dir is available
$RDIFFBIN --test-server $BACKUPSERVER::$BACKUPDIR >$TMPFILE 2>&1 || { f_error "$BACKUPSERVER not reachable"; }
ssh -q $BACKUPSERVER "test -d $BACKUPDIR" || { f_error "$BACKUPDIR on $BACKUPSERVER not present. Create it first"; }

printf "++++++++++++++++++++++ Backup Start at `date +"%H:%M:%S"` +++++++++++++++++++++++\n" >$TMPFILE

DISTRO=`lsb_release -i |awk '{print $3}'`
echo "Creating installed packages list $PKGLIST" >>$TMPFILE
case $DISTRO in
	Debian|Raspbian)
		dpkg --get-selections |egrep "\sinstall$" |awk '{print $1}' > $PKGLIST
	;;
	RedHatEnterpriseServer)
		rpm -qa >$PKGLIST
	;;
	*)
		echo "Could not determine Linux distribution or lsb_release not installed. Package list skipped..." >>$TMPFILE
	;;
esac
													 
[[ "$MYSQLBACKUP" == "true" ]] && f_mysqldump

[[ "$POSTGRESBACKUP" == "true" ]] && f_postgresqldump

[[ "$LDAPBACKUP" == "true" ]] && f_ldapbackup

#  Building include list
for FOLDER in $FOLDERS; do
	INCLUDEFOLDERS="$INCLUDEFOLDERS --include $FOLDER "
done

# Show what will be changed
printf "\n$TXT01\n# Backup of folders $FOLDERS (`date +"%H:%M:%S"`):\n$TXT01\n" >>$TMPFILE
echo "--------------[ Change statistics ]--------------" >>$TMPFILE
for FOLDER in $FOLDERS; do
	$RDIFFBIN --compare $FOLDER $BACKUPSERVER::$BACKUPDIR$FOLDER >>$TMPFILE
done

# Do the backup
$RDIFFBIN $RDIFFPARAMS $INCLUDEFOLDERS --exclude '**' / $BACKUPSERVER::$BACKUPDIR >>$TMPFILE

# Retention
$RDIFFBIN --remove-older-than $RETENTION --force $BACKUPSERVER::$BACKUPDIR >>$TMPFILE

echo "--------------[ Incremental statistics ]--------------" >>$TMPFILE
$RDIFFBIN -l $BACKUPSERVER::$BACKUPDIR >>$TMPFILE

printf "\n++++++++++++++++++++++ Backup End at `date +"%H:%M:%S"` +++++++++++++++++++++++" >>$TMPFILE
TIMESTOP=`date +%s`
printf "\n++++++++++++++++++++++ Duration `expr $TIMESTOP - $TIMESTART`sec +++++++++++++++++++++++" >>$TMPFILE

f_sendmail
exit 0

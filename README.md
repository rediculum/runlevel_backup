# Runlevel.ch Backup Framework
This is the runlevel.ch backup framework developed by [Roland Hansmann](https://github.com/rediculum)

Tested on plaform families ''debian'' and ''redhat''
## Requirements
 - lsb_release
 - mailx (bsd version)
 - keychain
 - rdiff-backup

## Installation
### Ansible
The easiest way is to use the [Ansible role](https://galaxy.ansible.com/rediculum/runlevel_backup). It will install all necessary dependencies and the download the framework from github
`$ ansbile-galaxy install rediculum.runlevel_backup`
### Manual
Clone the github repos
```
git clone https://github.com/rediculum/runlevel_backup.git
```
Create the directory
```
sudo mkdir -p /opt/runlevel_backup
```
Copy data
```
sudo cp -r opt/runlevel_backup/* /opt/runlevel_backup
sudo cp -r etc/cron.d/* /etc/cron.d
```
## Configuration
### Ansible
See the available vars in the role's default/main.yml if you want to override them
### Manual
Edit the file `/opt/runlevel_backup/backup.conf` and change the variables to fit your needs:
- `FOLDERS` - Array of folders to backup
- `BACKUPSERVER` - Targert server for backup
- `BACKUPDIR` - Target directory on backup server
- `PKGLIST` - Location of package list
- `MYSQLBACKUP` - Backup MySQL?
- `MYSQLUSER` - MySQL user
- `MYSQLPASS` - MySQL password
- `MYSQLBACK` - MySQL dump directory
- `POSTGRESBACKUP` - Backup Postgres?
- `PGSQLBACK` - Postgres dump directory
- `LDAPBACKUP` - Backup LDAP?
- `LDAPBACK` - LDAP dump directory
- `LDIFFILE` - LDIF file name
- `RETENTION` - How many backup to keep in months
- `EMAIL` - Email recipient for notification
- `FROM` - From address

Edit the cron file `/etc/cron.d/runlevel_backup` if you want to change the time when a backup is performed

## License
This project is licensed under the GNU Affero General Public License v3.0 License - see the [LICENSE](LICENSE) file for details

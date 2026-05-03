# Runlevel.ch Backup Framework
This is the runlevel.ch backup framework developed by [Roland Hansmann](https://github.com/rediculum)

Tested on platform families ''debian'' and ''redhat''
## Requirements
 - lsb_release
 - mailx (bsd version)
 - rdiff-backup

## Installation
### Ansible
The easiest way is to use the [Ansible role](https://galaxy.ansible.com/rediculum/runlevel_backup). It will install all necessary dependencies, download the framework from github and generates the necessary files.
```
$ ansbile-galaxy install rediculum.runlevel_backup
```
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
Generate SSH Keys
```
sudo ssh-keygen -t ed25519 -C runlevel_backup -f /opt/runlevel_backup/backup.key -q -N ""
```
Put the generated public key into root's ```authorized_keys``` and specify the command restriction for more security!
```
command="/opt/runlevel_backup/backup_ssh_cmnd.sh",no-agent-forwarding,no-port-forwarding,no-user-rc,no-X11-forwarding,no-pty ssh-ed25519 AAAAXXXXXXXXXXXXXX runlevel_backup
```
### Ansible
See the default/main.yml for all configuration options and override them by specifying in your inventory or group_vars. Run a playbook with the role "rediculum.runlevel_backup" and all is done.

### Manual
Edit the file `/opt/runlevel_backup/backup.conf` and change the variables to fit your needs:
- `FOLDERS` - Array of folders to backup
- `EXCLUDES` - Array of folders or files to exclude from backup
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

## Authors
* **Roland Hansmann** - *Initial work* - [Roland Hansmann](https://github.com/rediculum)

See also the list of [contributors](https://github.com/rediculum/runlevel_backup/graphs/contributors) who participated in this project.

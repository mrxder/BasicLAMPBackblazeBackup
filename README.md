# BasicLAMPBackblazeBackup
This is a basic backup script for a LAMP Server.
As a backup destination, Backblaze B2 is used.

With this script, it is easy to dump SQL Databases and copy the specified directories.

Because B2 support file versioning, this backup solution makes incremental backups with an adjustable parameter how long different versions of a file survive. 

# Installation
- Setup the b2 CLI tool as described in the b2 documentation.
- Configure the backup script with the backup.conf file.
- Adjust the path in the backup.sh script where the conf file gets sourced to your location.
- Set up a cron job the execute the script regularly:
- `20 2 * * * /root/backup_script/./backup.sh`
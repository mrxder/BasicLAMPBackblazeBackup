#! /bin/bash
command -v gzip >/dev/null 2>&1 || { echo >&2 "I require gzip but it's not installed.  Aborting."; exit 1; }
command -v b2 >/dev/null 2>&1 || { echo >&2 "I require b2 but it's not installed.  Aborting."; exit 1; }

# SetConfigLocation
. /root/backup_script/backup.config

# Backup Directories
for i in "${LOCATIONS[@]}"
do
   IFS=';' read -ra parts <<< "$i"
   b2 sync --keepDays $keepDays --replaceNewer ${parts[1]} b2://$B2_Bucket/${parts[0]}
done

# Backup SQL
mkdir tempSqlBackup
cd tempSqlBackup

for i in "${DATABASES[@]}"
do
   mysqldump -u "$DB_USER" -p"$DB_PW" "$i" | gzip -c > "$i.sql.gz"
done

cd ..

b2 sync --keepDays $keepDays --replaceNewer tempSqlBackup/ b2://$B2_Bucket/sql_db

rm -r tempSqlBackup



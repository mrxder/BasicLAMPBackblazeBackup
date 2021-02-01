#! /bin/bash
command -v gzip >/dev/null 2>&1 || { echo >&2 "I require gzip but it's not installed.  Aborting."; exit 1; }
command -v b2 >/dev/null 2>&1 || { echo >&2 "I require b2 but it's not installed.  Aborting."; exit 1; }

# SetConfigLocation
. /root/backup_script/backup.config

startTimeDate=$(date +%Y-%m-%d_%H-%M)
logFilePath="${logDir}backup_${startTimeDate}.log"

echo "-------- START BACKUP ---------" > "$logFilePath"
date >> "$logFilePath"
echo "-------------------------------" >> "$logFilePath"

# Backup Directories
for i in "${LOCATIONS[@]}"
do
   IFS=';' read -ra parts <<< "$i"
   echo "Backup directory ${parts[0]}" >> "$logFilePath"
   b2 sync --keepDays $keepDays --replaceNewer ${parts[1]} b2://$B2_Bucket/${parts[0]} >> "$logFilePath"
done

# Backup SQL
mkdir tempSqlBackup
cd tempSqlBackup

for i in "${DATABASES[@]}"
do
   echo "Dump DB $i" >> "$logFilePath"
   mysqldump -u "$DB_USER" -p"$DB_PW" "$i" | gzip -c > "$i.sql.gz"
done

cd ..

b2 sync --keepDays $keepDays --replaceNewer tempSqlBackup/ b2://$B2_Bucket/sql_db >> "$logFilePath"

rm -r tempSqlBackup

echo "--------- END BACKUP ----------" >> "$logFilePath"
date >> "$logFilePath"
echo "-------------------------------" >> "$logFilePath"

# Compress Log File
cat $logFilePath | gzip -c > "${logFilePath}.gz"
rm $logFilePath

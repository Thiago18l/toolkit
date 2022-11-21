#!/bin/bash
set -e


USER_DB=root
PASS=
BACKUP_ROOT="./backup/database/"
DATE=$(date +"%d-%m-%Y-%H-%M-%S")
BACKUP_DIR=${BACKUP_ROOT}${DATE}
install -d $BACKUP_DIR

FILE_LOG="$(date +"%d-%m-%Y-%H-%M-%S")-LOG-BACKUP.log"
LOG_ERROR_DIR="/tmp/logs-db-backup"
install -d $LOG_ERROR_DIR

BACKUP_START=$(date +"%d-%m-%Y-%H-%M-%S")
GZIP=$(which gzip)
INNOBACKUPEX=$(which innobackupex)

[[ -z ${INNOBACKUPEX} ]] && { echo "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Innobackupex not found in this OS"; } 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG} && exit 1;

echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): BACKUP INICIADO AS ${BACKUP_START}" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
${INNOBACKUPEX} --user=$USER_DB --password=$PASS --no-timestamp --parallel=12 --compress --compress-threads=12 $BACKUP_DIR 2>&1 | tee -a $LOG_ERROR_DIR/$FILE_LOG


cd $BACKUP_ROOT
tar -cf $DATE.tar $DATE
rm -rf $DATE


BACKUP_GZIP=$(find $BACKUP_ROOT -name $DATE.tar -type f -print)
GCLOUD=$(which gcloud)
BUCKET_NAME="legado-bucket"
[[ -z ${GCLOUD} ]] && { echo "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): GCLOUD CLI it's not installed" ; } 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG} && exit 1;
if [ -d $BACKUP_ROOT ] ; then
    $GCLOUD storage cp $BACKUP_GZIP gs://$BUCKET_NAME/ 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
else
    echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Folder not found"
    exit 1;
fi


echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): BACKUP FINALIZADO AS $(date +"%d-%m-%Y-%H-%M-%S")" | tee -a $LOG_ERROR_DIR/$FILE_LOG

# Removing old backups
echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Removing OLD Backups"
OLD_BACKUP=$(find $BACKUP_ROOT -name *.tar -type f -mtime +1 -print)
[[ -z $OLD_BACKUP ]] && { echo "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): FILE .tar not found in this folder"; } 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG} && exit 1;
echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Deleting ${OLD_BACKUP}" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
find $BACKUP_ROOT -name *.tar -type f -mtime +1 -delete 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}

# Verificando se foi apagado
FIND_BCKUP=$(find $BACKUP_ROOT -name *.tar -type f -mtime +1 -print)
if [ -z $FIND_BCKUP ] ; then
    echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Not found any backups older than one day" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
else
    echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Found a backup older than one day ${FIND_BCKUP}" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
fi

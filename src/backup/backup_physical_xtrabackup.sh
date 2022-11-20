#!/bin/bash

set -e

USER_DB=root
PASS=""
BACKUP_ROOT="./backup/database/"
DATE=$(date +"%d-%m-%Y-%H-%M-%S")
BACKUP_DIR=${BACKUP_ROOT}${DATE}
install -d $BACKUP_DIR

FILE_LOG="$(date +"%d-%m-%Y-%H-%M-%S")-LOG-BACKUP.log"
LOG_ERROR_DIR="/tmp/logs-db-backup"
install -d $LOG_ERROR_DIR

BACKUP_START=$(date +"%d-%m-%Y-%H-%M-%S")
GZIP=$(which gzip)
XTRABACKUP=$(which xtrabackup)

[[ -z ${XTRABACKUP} ]] && { echo "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): XTRABACKUP not found in this OS"; } 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG} && exit 1;

echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): BACKUP INICIADO AS ${BACKUP_START}" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
${XTRABACKUP} --backup -u ${USER_DB} -p ${PASS} --history --compress --parallel=12 --compress-threads=12 --target-dir=$BACKUP_DIR  2>&1 | tee -a $LOG_ERROR_DIR/$FILE_LOG


cd $BACKUP_ROOT
tar -cf $DATE.tar $DATE
$GZIP -9 $DATE.tar
rm -rf $DATE

mv $DATE.tar.gz web.tar.gz

BACKUP_GZIP=$(find $BACKUP_ROOT -name *.tar.gz -type f -print)
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
OLD_BACKUP=$(find $BACKUP_ROOT -name *.tar.gz -type f -mtime +1 -print)
[[ -z $OLD_BACKUP ]] && { echo "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): FILE .tar.gz not found in this folder"; } 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG} && exit 1;
echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Deleting ${OLD_BACKUP}" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
find $BACKUP_ROOT -name *.tar.gz -type f -mtime +1 -delete 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}

# Verificando se foi apagado
FIND_BCKUP=$(find $BACKUP_ROOT -name *.tar.gz -type f -mtime +1 -print)
if [ -z $FIND_BCKUP ] ; then
    echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Not found any backups older than one day" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
else
    echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Found a backup older than one day ${FIND_BCKUP}" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
fi
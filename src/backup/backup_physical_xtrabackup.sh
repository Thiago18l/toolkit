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


echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): BACKUP FINALIZADO AS $(date +"%d-%m-%Y-%H-%M-%S")" | tee -a $LOG_ERROR_DIR/$FILE_LOG
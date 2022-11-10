#!/bin/bash
set -e


USER_DB=root
PASS=
BACKUP_ROOT="./backup/database/"
DATE=$(date +"%d-%m-%Y-%H-%M-%S")
BACKUP_DIR=${BACKUP_ROOT}${DATE}


FILE_LOG="$(date +"%d-%m-%Y-%H-%M-%S")-LOG-BACKUP.log"
LOG_ERROR_DIR="/tmp/logs-db-backup"
install -d $LOG_ERROR_DIR

BACKUP_START=$(date +"%d-%m-%Y-%H-%M-%S")
GZIP=$(which gzip)
INNOBACKUPEX=$(which innobackupex)

[[ -z ${INNOBACKUPEX} ]] && { echo "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Innobackupex not found in this OS"; } 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG} && exit 1;

echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): BACKUP INICIADO AS ${BACKUP_START}" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
${INNOBACKUPEX} --user=$USER_DB --password=$PASS $BACKUP_DIR --no-timestamp --parallel=12 --compress --compress-threads=12 --defaults-file=/etc/my.cnf 2>&1 | tee -a $LOG_ERROR_DIR/$FILE_LOG

cd $BACKUP_ROOT
tar -cf $DATE.tar $DATE
$GZIP -9 $DATE.tar
rm -rf $DATE

echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): BACKUP FINALIZADO AS $(date +"%d-%m-%Y-%H-%M-%S")" | tee -a $LOG_ERROR_DIR/$FILE_LOG
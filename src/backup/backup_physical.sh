#!/bin/bash



USER_DB=
PASS=
HOST=
BACKUP_ROOT="/backup/database/"
DATE=$(date +"%d-%m-%Y-%H-%M-%S")
BACKUP_DIR=${BACKUP_ROOT}${DATE}


FILE_LOG="$(date +"%d-%m-%Y-%H-%M-%S")-LOG-BACKUP.log"
LOG_ERROR_DIR="/tmp/logs-db-backup"
install -d $LOG_ERROR_DIR

BACKUP_START=$(date +"%d-%m-%Y-%H-%M-%S")

INNOBACKUPEX=$(which innobackupex)

[[ -z ${INNOBACKUPEX} ]] && { echo "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): Innobackupex not found in this OS"; } 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG} && exit 1;

echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): BACKUP INICIADO AS ${BACKUP_START}" 2>&1 | tee -a $LOG_ERROR_DIR/${FILE_LOG}
innobackupex --user=$USER_DB --password=$PASS $BACKUP_DIR --no-timestamp --parallel=4 --compress --compress-threads=8 --defaults-file=/etc/my.cnf 2>&1 | tee -a $LOG_ERROR_DIR/$FILE_LOG

echo -e "INFO - $(date +"%d-%m-%Y-%H-%M-%S"): BACKUP FINALIZADO AS $(date +"%d-%m-%Y-%H-%M-%S")" | tee -a $LOG_ERROR_DIR/$FILE_LOG
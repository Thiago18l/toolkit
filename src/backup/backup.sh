#!/bin/bash
# Author: Thiago Lopes
# Shell Script para Backup do Banco de dados.
PATH_ENV=$(find ~/dev/toolkit-smart -name .env -print)
source ${PATH_ENV}
PORT="4308"

DESTINO="$HOME/database/" # /home/username/backups/db/
EMAIL="thiago.lopes.dev@gmail.com" # email para notification
DAYS=7

# Binarios linux necessarios
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

# Data referente ao dia.
DATA="$(date +"%d-%m-%Y-%H-%M-%S")"

# Arquivo de backup
BDB="${DESTINO}/${DATA}/mysql" # Pasta de backup
FILE="${BDB}/backup_${DATA}.sql"
install -d ${BDB}

# DB skip
SKIP="information_schema
#mysql50#my.cnf
performance_schema" # Caso seja necessario pular algum database

## Para caso de fazer o backup em um host remoto.
#mysqldump --opt --protocol=TCP --user=${USER} --password=${PASS} --host=${DBSERVER} ${DATABASE} > ${FILE}

# Para pegar todos os bancos.
DATABASES="$($MYSQL -h $HOSTDB -u $USERDB -p$PASS -P${PORT} -Bse "show databases")"

for db in ${DATABASES}
do
    skipdb=-1
    if [ "$SKIP" != "" ]; then
        for i in $SKIP; do
            [ "${db}" == "${i}" ] && skipdb=1 || :
        done
    fi

    if [ "${skipdb}" == "-1" ]; then
        FILE="${BDB}/backup_${db}_${DATA}.sql"
        $MYSQLDUMP --opt --protocol=TCP --column-statistics=0 --single-transaction --skip-lock-tables --user=${USERDB} --password=${PASS} --host=${HOSTDB} --port=${PORT} $db > $FILE
    fi
done

cd $DESTINO
tar -cf $DATA.tar $DATA
$GZIP -9 $DATA.tar

echo "MySQL backup foi concluido! Nome do backup é $DATA.tar.gz" | mail -s "MySQL backup" $EMAIL
rm -rf $DATA


# Removendo backups antigos
find $DESTINO -mtime +$DAYS -exec rm -f {} \;
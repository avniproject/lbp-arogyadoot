#!/bin/env bash

tstamp=$(date -Iseconds)
log=$HOME/.cronpgbkp/$2.$tstamp.log
sql=$HOME/.cronpgbkp/$2.$tstamp.sql

mkdir -p $HOME/.cronpgbkp

echo "[$tstamp] Starting" >> $log
sudo service postgresql-9.6 start 1>>$log 2>&1

until /usr/pgsql-9.6/bin/pg_isready -h localhost 1>>$log 2>&1
do
    echo "[$tstamp] Waiting" >> $log
    sleep 5
done

echo "[$tstamp] Postgres Service Ready" >> $log

/usr/pgsql-9.6/bin/pg_dump -U$1 -hlocalhost $2 > $sql 2>> $log

echo "[$tstamp] Backup done" >> $log

# At Reboot
# @reboot $HOME/.cronpgbkp.sh admin openchs
# @reboot $HOME/.cronpgbkp.sh admin reportingdb
#
# Hourly
# 0 */1 * * * $HOME/.cronpgbkp.sh admin openchs
# 30 */1 * * * $HOME/.cronpgbkpdel.sh openchs*.sql 10
# 30 */1 * * * $HOME/.cronpgbkpdel.sh openchs*.log 10
#
# Every 3 Hours
# 0 */3 * * * $HOME/.cronpgbkp.sh admin reportingdb
# 30 */3 * * * $HOME/.cronpgbkpdel.sh reportingdb*.sql 2
# 30 */3 * * * $HOME/.cronpgbkpdel.sh reportingdb*.log 2
#
# visudo
# admin ALL=(ALL) NOPASSWD: /home/admin/.cronpgbkp.sh
# admin ALL=(ALL) NOPASSWD: /home/admin/.cronpgbkpdel.sh
#

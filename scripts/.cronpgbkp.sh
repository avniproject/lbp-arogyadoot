#!/usr/bin/env bash

PATH=postgres-path:$PATH
tstamp=$(date -Iseconds)
log=$HOME/.cronpgbkp/$2.$tstamp.log
sql=$HOME/.cronpgbkp/$2.$tstamp.sql

mkdir -p $HOME/.cronpgbkp

until pg_isready -h localhost 1> /dev/null 2>> $log
do
    echo Waiting >> $log
    sleep 1
done

echo 'Postgres Service Ready' >> $log

pg_dump -U$1 -hlocalhost $2 > $sql 2>> $log

echo 'Backup done' >> $log

# At Reboot
# @reboot $HOME/.cronpgbkp.sh admin openchs
# @reboot $HOME/.cronpgbkp.sh admin reportingdb
#
# Hourly
# 0 */1 * * * $HOME/.cronpgbkp.sh admin openchs
# 0 */1 * * * $HOME/.cronpgbkpdel.sh openchs*.sql 10
# 0 */1 * * * $HOME/.cronpgbkpdel.sh openchs*.log 10
#
# Every 3 Hours
# 0 */3 * * * $HOME/.cronpgbkp.sh admin reportingdb
# 0 */3 * * * $HOME/.cronpgbkpdel.sh reportingdb*.sql 2
# 0 */3 * * * $HOME/.cronpgbkpdel.sh reportingdb*.log 2
#

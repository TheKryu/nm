#!/bin/sh

dbfile="/db/msensors.db"
ddt=`echo "$(date +'%Y-%m-%d')"`
log='/var/log/clear_db.log'

echo "$(date +'%Y-%m-%d %H:%M:%S') $dbfile, $ddt" >> $log

# -------------------------------------------------------------------------------------------------------------------------------
# move date < week to data_all average daily values

sql="insert into data_all select date, sens_id, round(avg(value),2) from data where date(date)<date('now', '-7 days') group by 2;"
echo "$sql" >> $log
echo "$sql" | sqlite3 ${dbfile} 2>&1 | tee -a $log

sql="delete from data where date(date)<date('now', '-7 days');"
echo "$sql" >> $log
echo "$sql" | sqlite3 ${dbfile} 2>&1 | tee -a $log

# clear week values exept hourly

sql="delete from data where datetime(date)<datetime('now','localtime','-24 hours') and strftime('%M', date) != '30'";
echo "$sql" >> $log
echo "$sql" | sqlite3 ${dbfile} 2>&1 | tee -a $log

echo "VACUUM;" | sqlite3 ${dbfile} 2>&1 | tee -a $log

exit 0


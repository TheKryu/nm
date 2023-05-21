#!/bin/bash

# ---------------------------------------------
# Save SENSORRS value to sqlite3 db V0.1
# ---------------------------------------------
# 16.10.2017
# ---------------------------------------------
# get data format from arduino (hardcoded)
# ###;SHT21_TEMP;SHT21_HMDTY;BMP180_PRES;BMP180_TEMP;DBS18B20_TEMP;DHT21_TEMP;DHT21_HMDTY;DHT21_IN_TEMP;DHT21_IN_HMDTY
#     1          2           3           4           5             6          7            8            9
#

log="/var/log/sens2db.log"
dtfmt="+%Y-%m-%d %H:%M:%S"
datafile=/tmp/sens_data
#datafile=/tmp/sensors.dat
db=/db/msensors.db
#db=/db/ms_test.db

#
# write to log file
#

wlog()
{
  echo "$(date "$dtfmt") $1" 2>&1 | tee -a $log
}

###

if [ ! -e $datfile ]
then
    wlog "Sensors data file $datafile not found!"
    exit 1
fi

if [ ! -e $db ]
then
    wlog "Database file $db not found!"
    exit 1
fi

# check for file time less then 10 min.

sdt=`stat --format=%y $datafile | cut -c1-19`

cl=`/usr/bin/find $datafile -cmin +10 | wc -l`
if [ $cl -ne 0 ]
then
    wlog "Sensors data file $datafile was last updated at $sdt > 10 min!!!" 
#    exit 1
fi

echo $sdt

# -------------------------

sd=`cat "$datafile"`

# 1 sht21 temp
sens1=`/bin/cat $datafile | /usr/bin/cut -d';' -f 2`

# 2 sht21 humidity
sens2=`/bin/cat $datafile | /usr/bin/cut -d';' -f 3`

# 3 bmp180 press
sens3=`/bin/cat $datafile | /usr/bin/cut -d';' -f 4`

# 4 bmp180 temp
sens4=`/bin/cat $datafile | /usr/bin/cut -d';' -f 5`

# 5 ds18b20 temp
sens5=`/bin/cat $datafile | /usr/bin/cut -d';' -f 6`

# 6 out dht21 temp
sens6=`/bin/cat $datafile | /usr/bin/cut -d';' -f 7`

# 7 out dht21 humidity
sens7=`/bin/cat $datafile | /usr/bin/cut -d';' -f 8`

# 8 in dht21 temp
sens8=`/bin/cat $datafile | /usr/bin/cut -d';' -f 9`

# 9 in dht21 humidity
sens9=`/bin/cat $datafile | /usr/bin/cut -d';' -f 10`

wlog "$datafile[$sdt]-->$sd"

####

#wlog "$db"

# check for date is already in db

#dtid=`echo "select id from dates where date='$sdt';" | sqlite3 -noheader $db`
#echo "$dtid"

#if [ ! -z "$dtid" ]
#then
#  wlog "Date=$sdt already in db (dates.id=$dtid)!"
#  exit 1
#fi


# check for date is already in db

dtid=`echo "select date from data where date='$sdt';" | sqlite3 -noheader $db`
#echo "$dtid"

if [ ! -z "$dtid" ]
then
  wlog "Date=$sdt already in db!"
  exit 1
fi

# --- insert data

cat << EOF | sqlite3 $db 2>&1 | tee -a $log
INSERT INTO data (sens_id, value, date) VALUES('1', $sens1, '$sdt');
INSERT INTO data (sens_id, value, date) VALUES('2', $sens2, '$sdt');
INSERT INTO data (sens_id, value, date) VALUES('3', $sens3, '$sdt');
INSERT INTO data (sens_id, value, date) VALUES('4', $sens4, '$sdt');
INSERT INTO data (sens_id, value, date) VALUES('5', $sens5, '$sdt');
INSERT INTO data (sens_id, value, date) VALUES('6', $sens6, '$sdt');
INSERT INTO data (sens_id, value, date) VALUES('7', $sens7, '$sdt');
INSERT INTO data (sens_id, value, date) VALUES('8', $sens8, '$sdt');
INSERT INTO data (sens_id, value, date) VALUES('9', $sens9, '$sdt');
EOF

exit 0


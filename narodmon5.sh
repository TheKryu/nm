#!/bin/bash

# ---------------------------------------
# Send arduino sensor data to narodmon.ru
# ---------------------------------------
# ###;SHT21_TEMP;SHT21_HMDTY;BMP180_PRES;BMP180_TEMP;DBS18B20_TEMP;DHT21_TEMP;DHT21_HMDTY;DHT21_IN_TEMP;DHT21_IN_HMDTY

log="/var/log/narodmon5.log"
dtfmt="+%Y-%m-%d %H:%M:%S"
datfile="/tmp/sens_data"

if [ ! -e "$datfile" ]
then
    echo "$(date $dtfmt) Sensors data file $datfile not found!" >> $log
    exit 1
fi

sdt=`stat --format=%y $datfile | cut -c1-19`

# -------------------------

SERVER="narodmon.ru"
PORT="8283"

#ping "$SERVER" -c 3 | grep "ttl"  > /dev/null

#if [ $? -ne 0 ]
#then
#    echo "$(date) Server: $SERVER not available!" >> $log
#    exit 1
#fi

# --------------------------

deviceMAC="ABCDEF012345"

sensID1=$deviceMAC"01"
sensID2=$deviceMAC"02"
sensID6=$deviceMAC"06"
sensID7=$deviceMAC"07"
sensID8=$deviceMAC"08"
sensID9=$deviceMAC"09"
sensID10=$deviceMAC"10"

sd=`cat "$datafile"`

# sht21 temp
sens1=`/bin/cat $datafile | /usr/bin/cut -d';' -f 2`

# sht21 humidity
sens2=`/bin/cat $datafile | /usr/bin/cut -d';' -f 3`

# bmp180 press
sens3=`/bin/cat $datafile | /usr/bin/cut -d';' -f 4`

# bmp180 temp
sens4=`/bin/cat $datafile | /usr/bin/cut -d';' -f 5`

# ds18b20 temp
sens5=`/bin/cat $datafile | /usr/bin/cut -d';' -f 6`


# bug with ds18b20 value = -0.06

r=`echo "$sens5 == -0.06" | bc -l`

if [ $r -eq 1 ]
then
  sens5=""
fi

# dht21 temp
sens6=`/bin/cat $datafile | /usr/bin/cut -d';' -f 7`

# dht21 humidity
sens7=`/bin/cat $datafile | /usr/bin/cut -d';' -f 8`

echo "$(date "$dtfmt") $datafile:$sdt --> $sd" >> $log

# set connection

exec 4<>/dev/tcp/$SERVER/$PORT

echo -e "#$deviceMAC\n\
#$sensID1#$sens6\n\
#$sensID2#$sens7\n\
#$sensID6#$sens1\n\
#$sensID7#$sens2\n\
#$sensID8#$sens3\n\
#$sensID9#$sens4\n\
#$sensID10#$sens5\n\
##" > /tmp/send_sens_data

cat /tmp/send_sens_data >&4

read -r MSG_IN <&4
echo "$MSG_IN"

echo "$(date "$dtfmt") $MSG_IN" >> $log

exec 4<&-
exec 4>&-

exit 0

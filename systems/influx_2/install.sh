#!/bin/sh

sudo killall --user influxdb
sudo killall --user telegraf
sudo kill -9 $(sudo lsof -t -i:8080)
ps -ef | grep 'influx' | grep -v grep | awk '{print $2}' | sudo xargs -r kill -9

sleep 10

sudo systemctl stop influxd

pip3 install influxdb

curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key
echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum --check - && cat influxdata-archive.key \
| gpg --dearmor \
| sudo tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list
# Install influxdb
sudo apt-get update && sudo apt-get install influxdb2


wget https://download.influxdata.com/influxdb/releases/influxdb2-2.7.11_linux_amd64.tar.gz
tar xvzf ./influxdb2-2.7.11_linux_amd64.tar.gz
rm influxdb2-2.7.11_linux_amd64.tar.gz
#sudo ./influxdb-1.7.10-1/usr/bin/influxd &
# cp influxdb.conf influxdb-2.7.11/etc/influxdb/influxdb.conf 

sudo chmod 0750 ~/.influxdbv2


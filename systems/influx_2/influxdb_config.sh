#!/bin/sh

# InfluxDB 2.x default setup values
INFLUX_HOST="http://192.168.112.142:8086"
INFLUX_USERNAME="name"
INFLUX_PASSWORD="password"
INFLUX_ORG="org"
INFLUX_ORG_ID=""  # Optional, can be left empty if not needed
INFLUX_BUCKET="gps_mpu"
INFLUX_TOKEN="mytoken"  # Optional, can be left empty if not needed
INFLUX_RETENTION="0"  # 0 means infinite retention

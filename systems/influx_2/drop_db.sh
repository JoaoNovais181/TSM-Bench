#!/bin/sh

. ./influxdb_config.sh

influx bucket delete -n d1 -o $INFLUX_ORG
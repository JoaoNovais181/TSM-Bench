#!/bin/sh

. ./influxdb_config.sh

log_file="influxdb.log"

# Start influxd in background as current user or root (if necessary)
./influxdb2-2.7.11/usr/bin/influxd > "$log_file" 2>&1 &
INFLUX_PID=$!
echo $INFLUX_PID > influxd.pid

sleep 5
echo "InfluxDB launched (PID: $INFLUX_PID)"

# Retry loop to wait for InfluxDB to become ready

MAX_RETRIES=10
RETRY_INTERVAL=5  # seconds
RETRY_COUNT=0

echo "Waiting for 'influx ping' to return OK..."

while true; do
    influx ping | grep -iq "^OK$"

    # Check if the last command was successful
    if [ $? -eq 0 ]; then
        break
    fi

    echo "InfluxDB not ready yet. Retrying in $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
        echo "'influx ping' did not return OK after $MAX_RETRIES attempts. Aborting setup."
        exit 1
    fi
done

echo "'influx ping' returned OK. Proceeding with setup..."

# check if configuration file for exists in ~/.influxdbv2
if [ ! -f ~/.influxdbv2/configs ]; then
    echo "Configuration file not found. Copying default configuration..."
    influx setup --username "$INFLUX_USERNAME" \
                --password "$INFLUX_PASSWORD" \
                --org "$INFLUX_ORG" \
                --bucket "$INFLUX_BUCKET" \
                --retention "$INFLUX_RETENTION" \
                --token "$INFLUX_TOKEN" \
                --force
else
    echo "Configuration file already exists. Skipping copy."
fi


echo "InfluxDB 2.x installed and configured successfully."
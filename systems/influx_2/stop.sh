#!/bin/sh

echo "Stopping InfluxDB and Telegraf services and processes..."

if [ -f influxd.pid ]; then
  PID=$(cat influxd.pid)
  echo "Stopping influxd (PID: $PID)"
  sudo kill "$PID"
  rm influxd.pid
else
  echo "No influxd.pid file found. Cannot stop InfluxDB safely."
fi

# Kill user processes (if running under current user)
sudo killall --user influxdb
sudo killall --user telegraf

# Kill anything using port 8080 (used in Telegraf outputs or custom APIs, adjust if needed)
sudo kill -9 $(sudo lsof -t -i:8080) 2>/dev/null

# Kill any remaining influx-related processes
ps -ef | grep 'influx' | grep -v grep | awk '{print $2}' | sudo xargs -r kill -9

# Give the system a moment
sleep 5

# Stop and disable system services
sudo systemctl stop influxdb influxd telegraf
sudo systemctl disable influxdb influxd telegraf

# Optional: Clean up system cache or temp files (uncomment if needed)
# sudo rm -rf /var/lib/influxdb /etc/influxdb



echo "InfluxDB and Telegraf have been stopped and disabled."
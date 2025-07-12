#!/bin/sh

# THE FOLLOWING SCRIPT WILL PRINT STORAGE SIZE FOR D1, TO SHOW D2 UNCOMMENT THE LINES BELOW 
dataset="d1"
if [ $# -ge 1 ]; then
    dataset="$1"
fi

# find id of the bucket

bucket_id=$(influx bucket list | grep -i "\s$dataset\s" | awk '{print $1}')

output=$(sudo du -sh ~/.influxdbv2/engine/data/$bucket_id | awk '{print $1}')
result=$(echo "$output" | awk '{print $1}')

echo "$result"

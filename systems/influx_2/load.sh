#!/bin/sh

# THE FOLLOWING SCRIPT WILL SETUP AND LOAD D1, TO LOAD D2 UNCOMMENT THE LINES BELOW 
# sh launch.sh

. ./influxdb_config.sh

dataset="gps_mpu"
if [ $# -ge 1 ]; then
    dataset="$1"
fi
echo $dataset

echo "convert the datase tformat (this takes a while and is not counted in the time measuring)"
# python3 generate_influx_line_protocol.py $dataset

# remove bucket if it exists

influx bucket list --host $INFLUX_HOST --token=$INFLUX_TOKEN | grep -iq "\s$dataset\s"
if [ $? -eq 0 ]; then
    echo "Bucket $dataset already exists. Deleting it..."
    influx bucket delete -n "$dataset" -o "$INFLUX_ORG" --token=$INFLUX_TOKEN --host $INFLUX_HOST
fi

# create bucket
influx bucket create --host $INFLUX_HOST -n "$dataset" -o "$INFLUX_ORG" --token=$INFLUX_TOKEN --retention "$INFLUX_RETENTION"

log_file="influx_startup.txt"
start_time=$(date +%s.%N)

echo "start loading"

influx write -b $dataset --host $INFLUX_HOST -o $INFLUX_ORG --token=$INFLUX_TOKEN -f $dataset-headers.csv -f $dataset-influxdb.csv -p ns --format=csv

# for now just waiting until the influx write command is done
# TODO find a way to replicate influx1.X behaviour


# # Initialize the last_line variJasable
# last_line=0

# # Continuously monitor the log file for new lines
# while : ; do
#   # Get the current line count
#   current_lines=$(awk 'END {print NR}' "$log_file")

#   echo "$current_lines"

#   # Check if there are new lines since the last check
#   if [ "$current_lines" -gt "$last_line" ]; then
#     # Print the new lines
#     sed -n "$((last_line + 1)),$current_lines p" "$log_file"

#     # Update the last_line variable
#     last_line="$current_lines"

#     # Check if any line in the new lines contains "failed"
#     if grep -q "Failed" "$log_file"; then
#       echo "Final message detected! Exiting..."
#       break  # Exit the loop when "failed" is found
#     fi

#   fi

#   sleep 5  # Wait for a few seconds before checking again
# done
# rm $log_file


end_time=$(date +%s.%N)
elapsed_time=$(echo "$end_time - $start_time" | bc)
elapsed_time=$(printf "%.2f" "$elapsed_time")
echo $elapsed_time

# find number of entries in the dataset
num_entries=$(wc -l < $dataset-influxdb.csv)
num_entries=$(echo "$num_entries - 1" | bc) # remove header

inserted_entries=$(influx query --host $INFLUX_HOST --token=$INFLUX_TOKEN -o $INFLUX_ORG 'from(bucket:"'"$dataset"'") |> range(start: 0) |> filter(fn: (r) => r._measurement == "sensor" and r._field == "speed") |> count()' | awk '/\s[0-9]+/ {sum += $6} END {print sum}')

entries_per_second=$(echo "scale=4;$inserted_entries / $elapsed_time" | bc -l )
failed_insertions=$(echo "$num_entries - $inserted_entries" | bc)

echo "Inserted entries: $inserted_entries in $elapsed_time seconds. Avg: $entries_per_second entries/s"
echo "Failed insertions: $failed_insertions"

compression=$(sh compression.sh $dataset)

echo "Compression: $compression"
echo "$dataset ${elapsed_time}s ${compression}GB" >> time_and_compression.txt



echo "DONE"

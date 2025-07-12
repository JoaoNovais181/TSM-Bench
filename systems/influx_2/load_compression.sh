#!/bin/sh

# Launch InfluxDB
sh launch.sh

folder="datasets_influx"
if [ $# -ge 1 ]; then
    folder="$1"
fi

echo "Processing folder: $folder"

# Initialize the output file
results_dir="../../results/compression"
mkdir -p "$results_dir"
output_file="$results_dir/time_and_compression.txt"

echo "### InfluxDB" >> $output_file
echo "Dataset_name,Size" >> $output_file

for file_path in "$folder"/*-influxdb.csv; do
    # Extract the dataset name from the file
    dataset=$(basename "$file_path" "-influxdb.csv")
    echo "Processing dataset: $dataset"

    influx bucket list | grep -iq "\s$dataset\s"
    if [ $? -eq 0 ]; then
        echo "Bucket $dataset already exists. Deleting it..."
        influx bucket delete -n "$dataset" -o "$INFLUX_ORG"
    fi

    # create bucket
    influx bucket create -n "$dataset" -o "$INFLUX_ORG" --retention "$INFLUX_RETENTION"

    log_file="influx_startup_$dataset.txt"
    start_time=$(date +%s.%N)

    echo "Start loading $dataset"

    # Load the dataset into InfluxDB
    influx write -b $dataset -o $INFLUX_ORG -f $dataset-headers.csv -f $dataset-influxdb.csv -p ns --format=csv


    # # Monitor log file for errors
    # last_line=0
    # while : ; do
    #     current_lines=$(awk 'END {print NR}' "$log_file")

    #     if [ "$current_lines" -gt "$last_line" ]; then
    #         sed -n "$((last_line + 1)),$current_lines p" "$log_file"
    #         last_line="$current_lines"

    #         # Check for failure messages
    #         if grep -q "Failed" "$log_file"; then
    #             echo "Failed message detected for $dataset! Exiting..."
    #             break
    #         fi
    #     fi
    #     sleep 5
    # done
    # rm "$log_file"

    end_time=$(date +%s.%N)
    elapsed_time=$(echo "$end_time - $start_time" | bc)
    elapsed_time=$(printf "%.2f" "$elapsed_time")

    # Get the size of the file
    file_size=$(du -sh "$file_path" | cut -f1)
    echo "$dataset,$file_size" >> $output_file

    echo "Compression: $file_size"
    echo "$dataset loaded in ${elapsed_time}s"
done

echo "DONE"

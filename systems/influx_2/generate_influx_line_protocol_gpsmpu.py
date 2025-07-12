import datetime
import time
import sys


BEGIN_TIMESTAMP_NS = 1_735_689_600_000_000_000 # 01-01-2025 00:00:00 UTC
TIME_INTERVAL_NS = 100_000_000  # 100 ms in nanoseconds

dataset = "gps_mpu"
# Check if the correct number of arguments is provided
if len(sys.argv) != 2:
    print("Usage: python script.py <dataset>, defaults to gps_mpu")
else:
    dataset = sys.argv[1].split(".csv")[0]

print(f"transforming {dataset}")

field_names = [
    "timestamp",
    "device_id",
    "acc_x_dashboard",
    "acc_y_dashboard",
    "acc_z_dashboard",
    "acc_x_above_suspension",
    "acc_y_above_suspension",
    "acc_z_above_suspension",
    "acc_x_below_suspension",
    "acc_y_below_suspension",
    "acc_z_below_suspension",
    "gyro_x_dashboard",
    "gyro_y_dashboard",
    "gyro_z_dashboard",
    "gyro_x_above_suspension",
    "gyro_y_above_suspension",
    "gyro_z_above_suspension",
    "gyro_x_below_suspension",
    "gyro_y_below_suspension",
    "gyro_z_below_suspension",
    "mag_x_dashboard",
    "mag_y_dashboard",
    "mag_z_dashboard",
    "mag_x_above_suspension",
    "mag_y_above_suspension",
    "mag_z_above_suspension",
    "temp_dashboard",
    "temp_above_suspension",
    "temp_below_suspension",
    "latitude",
    "longitude",
    "speed",
]

data_src = open(f'../../datasets/{dataset}.csv')
data_target= open(f'{dataset}-influxdb.csv','w')
headers = open(f'{dataset}-headers.csv','w')
# head_line=f"#datatype measurement,tag,,dateTime:number"
headers.write(f"#constant measurement,sensor\n")
headers.write(f"#datatype dateTime:number,tag{30*',double'}\n")
data_target.write(",".join(field_names)+"\n")
index=1
loops=40
i=0
line = data_src.readline()
num_lines = 0

start = time.time()
while i<loops:
    line = data_src.readline()
    if not line:
        data_src.close()
        data_src = open(f'../../datasets/{dataset}.csv')
        if i==0:
            num_lines = index - 1
        i=i+1
        index=1

    if (line.strip() != ''):
        columns = line.split(",")
        # timestamp_str = columns[0]
        # seconds_str, nanos_str = timestamp_str.split(".")
        # nanos_str = nanos_str.ljust(9, '0')
        # timestamp_ns = int(seconds_str) * 1_000_000_000 + int(nanos_str)        
        timestamp_ns = BEGIN_TIMESTAMP_NS + index * TIME_INTERVAL_NS
        new_columns = []
        new_columns.append(str(timestamp_ns))
        new_columns.append(f"device_{i}")
        new_columns.extend(val for i,val in enumerate(columns[1::]) if i != 27)
        if len(new_columns) != 32:
            print("Invalid dataset")
            break
        out = ",".join(new_columns)
        if i==0 and index == 1:
            print(out)
        data_target.write(out)
        if((index + i*num_lines)%10000==0):
            print((index + i*num_lines), end="\r")
        index=index+1
print()
data_target.close()
headers.close()
data_src.close()
print(time.time()-start)

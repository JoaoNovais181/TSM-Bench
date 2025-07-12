import datetime
import time
import sys

dataset = "d1"
# Check if the correct number of arguments is provided
if len(sys.argv) != 2:
    print("Usage: python script.py <dataset>, defaults to d1")
else:
    dataset = sys.argv[1].split(".csv")[0]

print(f"transforming {dataset}")

data_src = open(f'../../datasets/{dataset}.csv')
data_target= open(f'{dataset}-influxdb.csv','w')
headers = open(f'{dataset}-headers.csv','w')
# head_line=f"#datatype measurement,tag,,dateTime:number"
headers.write(f"#constant measurement,sensor\n")
headers.write(f"#datatype dateTime:RFC3339,tag{100*',double'}\n")
data_target.write(f"date,id_station,{','.join([f's{i}' for i in range(0,100)])}\n")
index=1
line = data_src.readline()

start = time.time()
while True:
    line = data_src.readline()
    if not line:
        break
    if (line.strip() != ''):
        columns = line.split(",")
        columns[0]+="Z"
        out = ",".join(columns)
        data_target.write(out)
        if(index%10000==0):
            print(index, end="\r")
        index=index+1
print()
data_target.close()
headers.close()
data_src.close()
print(time.time()-start)

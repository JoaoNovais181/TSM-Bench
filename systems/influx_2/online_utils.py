import time, datetime
from influxdb_client import InfluxDBClient

def generate_insertion_query(time_stamps: list, station_ids: list, sensors_values, dataset):
    #generates string with influx query seperated by ;
    # convert time stmap to influx format
    time_stamps = [str(int(time.mktime(time.strptime(t, "%Y-%m-%dT%H:%M:%S")) * 1000)) for t in time_stamps]

    result = ""
    for t,station, sensor_values in zip(time_stamps, station_ids, sensors_values):
        result += f"sensor,id_station={station} "
        result += ",".join([f"s{i}={v}" for i, v in enumerate(sensor_values)])
        result += f" {t};"
    result = result[:-1] # remove last ;
    return result

def delete_data(date= "2019-04-1T00:00:00", host = "localhost", dataset = "d1"):
    print("cleaning up influx")
    start_seconds = time.time()
    # convert to 2019-12-24T20:19:56 format using start_seconds
    start = datetime.datetime.fromtimestamp(start_seconds).strftime('%Y-%m-%dT%H:%M:%SZ')

    client = InfluxDBClient(url=f"{host}:8086", username='name', token="mytoken", org="org")

    result = client.delete_api().delete(date, start, predicate='_measurement="sensor"', bucket=dataset, org="org")
    client.close()
    print(result)
    client.close()
    time.sleep(5)

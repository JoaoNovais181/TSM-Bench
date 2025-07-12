from systems import  influx ,extremedb, influx_2, timescaledb , questdb  , monetdb , clickhouse , druid


system_module_map = { "influx" : influx,
    "influx_2": influx_2,
    "extremedb" : extremedb,
    "clickhouse" : clickhouse,
    "questdb" : questdb,
    "monetdb" : monetdb,
    "druid" : druid,
    "timescaledb" : timescaledb
}
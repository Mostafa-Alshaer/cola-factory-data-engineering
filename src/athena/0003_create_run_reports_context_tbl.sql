CREATE EXTERNAL TABLE IF NOT EXISTS `cola_process_data_${environment}`.`run_reports_context_tbl`(
    `id` string,
    `type` string,
    `time` string,
    `branch_id` string,
    `machine_id` string
  )
ROW FORMAT SERDE
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION
  's3://cola-factory-process-data-${environment}/context/run_reports/tables/'
TBLPROPERTIES ('parquet.compression'='SNAPPY');
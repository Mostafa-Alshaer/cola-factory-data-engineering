CREATE EXTERNAL TABLE IF NOT EXISTS `cola_process_data_mostafadev`.`run_reports_batch_tbl` (
    `id` string,
    `type` string,
    `time` string,
    `branch_id` string,
    `machine_id` string
  )
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'field.delim' = ',',
  'serialization.format' = ','
)
LOCATION 's3://cola-factory-process-data-mostafadev/batch/run-reports'
TBLPROPERTIES ('has_encrypted_data'='false');

CREATE EXTERNAL TABLE `cola_process_data_mostafadev`.`run_reports_leftover_tbl`(
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
  's3://cola-factory-process-data-mostafadev/leftover/run-reports/tables/'
TBLPROPERTIES ('parquet.compression'='SNAPPY');

CREATE EXTERNAL TABLE `cola_process_data_mostafadev`.`run_reports_context_tbl`(
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
  's3://cola-factory-process-data-mostafadev/context/run-reports/tables/'
TBLPROPERTIES ('parquet.compression'='SNAPPY');
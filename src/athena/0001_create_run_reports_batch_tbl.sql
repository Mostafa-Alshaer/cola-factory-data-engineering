CREATE EXTERNAL TABLE IF NOT EXISTS `cola_process_data_${environment}`.`run_reports_batch_tbl` (
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
LOCATION 's3://cola-factory-process-data-${environment}/batch/run-reports/'
TBLPROPERTIES ('has_encrypted_data'='false');
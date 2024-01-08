-- context view
CREATE OR REPLACE VIEW run_reports_context_view AS
SELECT *
  FROM run_reports_batch_tbl
UNION
SELECT *
  FROM run_reports_leftover_tbl;
-- leftover view
CREATE OR REPLACE VIEW run_reports_leftover_view AS
WITH context_dataframe AS (
  SELECT *,
         "row_number"() OVER (
            PARTITION BY branch_id, machine_id ORDER BY time DESC
         ) row_number
    FROM run_reports_context_tbl
)
SELECT id,
       type,
       time,
       branch_id,
       machine_id
  FROM context_dataframe
    WHERE row_number = 1;
-- logic view
CREATE OR REPLACE VIEW run_reports_logic_view AS
WITH run_intervals_dataframe AS (
  SELECT id,
         type,
         "lead"(type,1) OVER (PARTITION BY branch_id, machine_id ORDER BY time) next_type,
         time start_time,
         "lead"(time,1) OVER (PARTITION BY branch_id, machine_id ORDER BY time) end_time,
         branch_id,
         machine_id
    FROM run_reports_context_tbl
)
SELECT type,
       start_time,
       end_time,
       branch_id,
       machine_id
  FROM run_intervals_dataframe
    WHERE type = 'start' AND next_type = 'stop'
-- to delete view
CREATE OR REPLACE VIEW run_reports_to_delete_view AS
SELECT DISTINCT(run."$path") AS s3_key
  FROM run_reports_batch_tbl run
    WHERE CONCAT(branch_id,machine_id,time) in (
      SELECT CONCAT(branch_id,machine_id,time)
        FROM run_reports_context_tbl
    )

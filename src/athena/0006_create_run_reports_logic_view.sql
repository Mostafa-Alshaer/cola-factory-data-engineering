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
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
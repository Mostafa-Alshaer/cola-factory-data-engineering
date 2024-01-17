CREATE OR REPLACE VIEW run_reports_to_delete_view AS
SELECT DISTINCT(run."$path") AS s3_key
  FROM run_reports_batch_tbl run
    WHERE CONCAT(branch_id,machine_id,time) in (
      SELECT CONCAT(branch_id,machine_id,time)
        FROM run_reports_context_tbl
    )
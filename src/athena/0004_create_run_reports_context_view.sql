CREATE OR REPLACE VIEW run_reports_context_view AS
SELECT *
  FROM run_reports_batch_tbl
UNION
SELECT *
  FROM run_reports_leftover_tbl;
resource "aws_athena_workgroup" "workgroup" {
  name = "cola_data_team_process_work_group_${var.environment}"
}
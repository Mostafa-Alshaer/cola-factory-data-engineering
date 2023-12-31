# define some local variables to be passed to the different modules
locals {
  environment = terraform.workspace
  region = var.region
}
# bucket for the raw data of the cola factory
module cola-factory-raw-data {
  source     = "../s3/buckets/cola-factory-raw-data"
  environment  = local.environment
}
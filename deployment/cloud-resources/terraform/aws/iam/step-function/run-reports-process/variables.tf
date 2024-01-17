variable "lambdas_arns" {
    description = "The list of lambdas arns that invoke by the run reports step function"
    type = list
    default = []
}
variable "environment" {
    description = "The environment name."
    type = string
}
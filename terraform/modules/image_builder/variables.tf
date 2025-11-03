variable "component_data_yaml" { type = string }
variable "component_name" { type = string }
variable "pipeline_infra_arn" { type = string }
variable "pipeline_name" { type = string }

variable "component_platform" {
  type    = string
  default = "Linux"
}

variable "component_version" {
  type    = string
  default = "1.0.0"
}


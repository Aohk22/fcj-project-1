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

variable "recipe_name" { type = string }
variable "recipe_parent_img" { type = string }

variable "recipe_version" {
  type    = string
  default = "1.0.0"
}

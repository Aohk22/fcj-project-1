variable "tg_name" { type = string }
variable "tg_port" { type = number }
variable "tg_protocol" { type = string }
variable "tg_vpc_id" { type = string }
variable "tg_dereg_delay" { 
  type = number
  default = 300
}
variable "tg_stickiness" {
  type = object({
    enabled         = bool
    type            = string
    cookie_duration = number
  })
  default = null
}

variable "hc_path" { type = string }
variable "hc_port" { type = string }
variable "hc_protocol" { type = string }
variable "hc_matcher" { type = string }

variable "asg_name" { type = string }
variable "asg_max_size" { type = number }
variable "asg_min_size" { type = number }
variable "asg_desired_capacity" { type = number }
variable "asg_subnet_ids" { type = list(string) }
variable "asg_lt_id" { type = string }


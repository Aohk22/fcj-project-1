variable "name" { type = string }
variable "image_id" { type = string }
variable "instance_type" { type = string }
variable "key_name" { type = string }
variable "user_data" { type = string }
variable "iam_instance_profile_name" { type = string }

variable "network_interfaces" {
  type = object({
    public_ip          = bool
    security_group_ids = optional(list(string))
  })
}

variable "tag_specifications" {
  type = object({
    tags = map(string)
  })
}


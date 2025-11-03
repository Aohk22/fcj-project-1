resource "aws_launch_template" "this" {
  name          = var.name
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  tags          = { Name = var.name }
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  network_interfaces {
    associate_public_ip_address = var.network_interfaces.public_ip
    security_groups             = var.network_interfaces.security_group_ids
  }
  tag_specifications {
    resource_type = "instance"
    tags          = var.tag_specifications.tags
  }
  user_data = base64encode(var.user_data)
}

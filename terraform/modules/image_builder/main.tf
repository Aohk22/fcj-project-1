// user resource: aws_imagebuilder_infrastructure_configuration.
resource "aws_imagebuilder_component" "this_component" {
  name     = var.component_name
  platform = var.component_platform
  version  = var.component_version
  data     = var.component_data_yaml
}

resource "aws_imagebuilder_image_recipie" "this_recipie" {
  name         = var.recipie_name
  parent_image = var.recipie_parent_img
  version      = var.recipie_version
  block_device_mapping {
    device_name = "/dev/xvdb"
  }
  ebs {
    delete_on_termination = true
    volume_size           = 13
    volume_type           = "gp2"
  }
  component {
    component_arn = aws_imagebuilder_component.this_component.arn
  }
  tags = {
    Name = var.recipie_name
  }
}

resource "aws_imagebuilder_image_pipeline" "this" {
  image_recipe_arn                 = aws_imagebuilder_image_recipie.this_recipie.arn
  infrastructure_configuration_arn = var.pipeline_infra_arn
  name                             = var.pipeline_name

  lifecycle {
    replace_triggered_by = [
      aws_imagebuilder_image_recipie.this_recipie
    ]
  }
}

#!/usr/bin/env sh

terraform plan -out=img_builder.tfplan \
  -target=aws_imagebuilder_infrastructure_configuration.imgbuilder_infra_config \
  -target=module.image_builder_pipeline_fhandle \
  -target=module.image_builder_pipeline_fquery \
  -target=module.instance_profile_imgbuilder \
  -target=aws_internet_gateway.igw_main \
  -target=aws_route_table.route_table_public \
  -target=aws_route_table_association.rt_associate_sn_pub_1 \
  -target=aws_iam_role_policy_attachment.imgbuilder_ec2_profile \
  -target=aws_iam_role_policy_attachment.imgbuilder_ec2_ecr_profile \
  -target=aws_iam_role_policy_attachment.imgbuilder_ssm_core

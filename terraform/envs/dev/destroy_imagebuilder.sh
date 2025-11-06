#!/usr/bin/env sh

terraform destroy \
  -target=aws_imagebuilder_infrastructure_configuration.imgbuilder_infra_config \
  -target=module.image_builder_pipeline_fhandle \
  -target=module.image_builder_pipeline_fquery

module "groups_service_fhandle" {
  source      = "../../modules/service_auto_scale"
  tg_name     = "fhandle-tg"
  tg_port     = 4100
  tg_protocol = "HTTP"
  tg_vpc_id   = module.vpc.id

  hc_path     = "/docs"
  hc_port     = "4100"
  hc_protocol = "HTTP"
  hc_matcher  = "200"

  asg_name             = "fhandle-asg"
  asg_max_size         = var.asg_size_max
  asg_min_size         = var.asg_size_min
  asg_desired_capacity = var.asg_size_desired
  asg_subnet_ids       = [module.subnet_prv_1.id, module.subnet_prv_2.id]
  asg_lt_id            = module.launch_template_fhandle.id
}

module "groups_service_fquery" {
  source      = "../../modules/service_auto_scale"
  tg_name     = "fquery-tg"
  tg_port     = 4101
  tg_protocol = "HTTP"
  tg_vpc_id   = module.vpc.id

  hc_path     = "/docs"
  hc_port     = "4101"
  hc_protocol = "HTTP"
  hc_matcher  = "200"

  asg_name             = "fquery-asg"
  asg_max_size         = var.asg_size_max
  asg_min_size         = var.asg_size_min
  asg_desired_capacity = var.asg_size_desired
  asg_subnet_ids       = [module.subnet_prv_1.id, module.subnet_prv_2.id]
  asg_lt_id            = module.launch_template_fquery.id
}

module "groups_service_web" {
  source      = "../../modules/service_auto_scale"
  tg_name     = "web-tg"
  tg_port     = 8000
  tg_protocol = "HTTP"
  tg_vpc_id   = module.vpc.id
  tg_dereg_delay = 3600
  tg_stickiness = {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 3600
  }

  hc_path     = "/"
  hc_port     = "8000"
  hc_protocol = "HTTP"
  hc_matcher  = "200"

  asg_name             = "web-asg"
  asg_max_size         = var.asg_size_max
  asg_min_size         = var.asg_size_min
  asg_desired_capacity = var.asg_size_desired
  asg_subnet_ids       = [module.subnet_pub_1.id, module.subnet_pub_2.id]
  asg_lt_id            = module.launch_template_web.id
}

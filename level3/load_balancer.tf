data "aws_route53_zone" "main" {
  name = "shotaro.click"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name         = "www.shotaro.click"
  zone_id             = data.aws_route53_zone.main.id
  wait_for_validation = true
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = var.env_code

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.level1.outputs.vpc_id
  internal        = false
  subnets         = data.terraform_remote_state.level1.outputs.public_subnet_id
  security_groups = [data.terraform_remote_state.level2.outputs.external_sg.security_group_id]


  target_groups = [
    {
      name_prefix          = var.env_code
      backend_protocol     = "HTTP"
      backend_port         = 80
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/readme.html"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      action_type        = "forward"
      target_group_index = 0
    }
  ]
}

module "dns" {
  source = "terraform-aws-modules/route53/aws//modules/records"

  zone_id = data.aws_route53_zone.main.zone_id

  records = [
    {
      name    = "www"
      type    = "CNAME"
      records = [module.alb.lb_dns_name]
      ttl     = 3600
    }
  ]
}

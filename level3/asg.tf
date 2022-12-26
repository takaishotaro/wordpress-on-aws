data "aws_ami" "amazonlinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "main" {
  name                = var.env_code
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]
  assume_role_policy  = <<EOF
{
    "Version": "2012-10-17",
    "Statement":[
        {
            
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "main" {
  name = var.env_code
  role = aws_iam_role.main.name
}

resource "aws_launch_configuration" "web_config" {
  image_id             = data.aws_ami.amazonlinux.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.main.name
  security_groups      = [data.terraform_remote_state.level2.outputs.private_sg.security_group_id]

  user_data = templatefile("user-data.tpl", {
    # db_username  = data.terraform_remote_state.level2.outputs.db_instance_username,
    # db_password  = data.terraform_remote_state.level2.outputs.db_instance_password,
    # db_name      = data.terraform_remote_state.level2.outputs.db_instance_name,
    # rds_endpoint = data.terraform_remote_state.level2.outputs.db_instance_endpoint,
    # wp_username  = var.wp_username,
    # wp_email     = var.wp_email,
    # wp_password  = var.wp_password,
    db_username  = "admin",
    db_password  = "takai326",
    db_name      = "mydb",
    rds_endpoint = "main.cngndrh55kuq.ap-northeast-1.rds.amazonaws.com:3306",
  })

}

resource "aws_autoscaling_group" "app-asg" {
  launch_configuration = aws_launch_configuration.web_config.id
  vpc_zone_identifier  = data.terraform_remote_state.level1.outputs.private_subnet_id
  target_group_arns    = module.alb.target_group_arns

  max_size = 2
  min_size = 2

  tag {
    key                 = "Name"
    value               = "${var.env_code}-asg"
    propagate_at_launch = true
  }
}

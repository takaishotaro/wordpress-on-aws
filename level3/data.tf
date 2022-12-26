data "terraform_remote_state" "level1" {
  backend = "remote"

  config = {
    organization = "tfclouddemo-takai"
    workspaces = {
      name = "wordpress-on-aws-level1"
    }
  }
}

data "terraform_remote_state" "level2" {
  backend = "remote"

  config = {
    organization = "tfclouddemo-takai"
    workspaces = {
      name = "wordpress-on-aws-level2"
    }
  }
}

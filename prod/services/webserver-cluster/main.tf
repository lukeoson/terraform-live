provider "aws" {
  region = "us-east-2" 
  default_tags {
    tags = {
      Owner     = "Lukeoson"
      ManagedBy = "Terraform"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "lukeoson-terraform-state-backend"
    key            = "prod/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-2"
  }
}

module "webserver_cluster" {
  #source = "../../../modules/services/webserver-cluster"
  source = "git::https://github.com/lukeoson/terraform-modules.git//services/webserver-cluster?ref=v0.1.0-alpha"

  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "lukeoson-terraform-state-backend"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 10 

  #custom_tags = {
  #  Owner     = "team-foo"
  #  ManagedBy = "terraform"
  #}
  
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  autoscaling_group_name = module.webserver_cluster.asg_name
  scheduled_action_name  = "scale-out-during-business-hours"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 10
  recurrence             = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  autoscaling_group_name = module.webserver_cluster.asg_name
  scheduled_action_name  = "scale-in-at-night"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
}


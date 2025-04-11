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
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-2"
  }
}

module "webserver_cluster" {
  #source = "../../../modules/services/webserver-cluster"
  source = "git::https://github.com/lukeoson/terraform-modules.git//services/webserver-cluster?ref=v0.2.0-aplha"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "lukeoson-terraform-state-backend"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
  custom_tags = {
    Owner     = "team-foo-stage"
    ManagedBy = "terraform"
  }

}
resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}



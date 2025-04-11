terraform {
  backend "s3" {
    # Your bucket name!
    bucket         = "lukeoson-terraform-state-backend"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"

    # Your DynamoDB table name!
    dynamodb_table = "terraform_locks"
    encrypt        = true
  }
}

provider "aws" {
    region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "stage-lukeoson-terraform"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "example_database"

  # How should we set the username and password?
  username = var.db_username
  password = var.db_password
}
variable "profile" {}

provider "aws" {
  region  = "ap-northeast-1"
  profile = var.profile
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = var.profile
}

terraform {
  required_version = "1.2.5"
  backend "s3" {
    bucket         = "terraform-aurora-sample-tfstate"
    region         = "ap-northeast-1"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-aurora-sample-state-locking"
  }
}

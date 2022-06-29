terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws   = ">= 3.22.0"
    local = ">= 1.4"
    null  = ">= 2.1"
    # template   = ">= 2.1"
    random     = ">= 2.1"
    kubernetes = ">= 1.18"
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.5.1"
    }
  }
  backend "s3" {
    bucket = "drona-test-terraform"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
provider "aws" {
  region = "ap-south-1"
  # profile = var.project
}

# ========
# Provider
# ========
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.0.0"
    }
  }
    cloud {
    organization = "nbdevlab"
    workspaces {
      name = "PROJECT_NAME"
    }
  }  
}
provider "cloudflare" {
}
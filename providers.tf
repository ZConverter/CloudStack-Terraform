terraform {
  required_providers {
    cloudstack = {
      source = "cloudstack/cloudstack"
      version = "0.4.0"
    }
  }
}

provider "cloudstack" {
  api_url    = var.generate.auth.api_url
  api_key    = var.generate.auth.api_key
  secret_key = var.generate.auth.secret_key
}

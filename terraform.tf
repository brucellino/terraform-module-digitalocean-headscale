terraform {
  required_version = "~> 1.16"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.24.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.4.1"
    }
  }
}

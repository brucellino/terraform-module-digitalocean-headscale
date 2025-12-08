terraform {
  backend "consul" {
    path = "terraform/modules/digitalocean-headscale/test"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">=3.11.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">=2.24.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=3.28.0"
    }
  }
}
variable "vault_mount_path_digitalocean" {
  type        = string
  default     = "digitalocean"
  description = "Path in Vault to the Digital Ocean secrets"
}

variable "do_secret" {
  type        = string
  description = "Name of the secret in the vault mount for Digital Ocean tokens"
  default     = "tokens"
}

variable "vault_mount_path_cloudflare" {
  type        = string
  default     = "cloudflare"
  description = "Path in Vault to the Digital Ocean secrets"
}

variable "cloudflare_secret" {
  type        = string
  description = "Name of the secret in the vault mount for Digital Ocean tokens"
  default     = "terraform"
}
provider "vault" {}

data "vault_kv_secret_v2" "do" {
  mount = var.vault_mount_path_digitalocean
  name  = var.do_secret
}

data "vault_kv_secret_v2" "cloudflare" {
  mount = var.vault_mount_path_cloudflare
  name  = var.cloudflare_secret
}
provider "digitalocean" {
  token = data.vault_kv_secret_v2.do.data["terraform"]
}
provider "cloudflare" {
  api_token = data.vault_kv_secret_v2.cloudflare.data["headscale_api_token"]
  # api_user_service_key = data.vault_kv_secret_v2.cloudflare.data["origin_ca_key"]
}


module "example" {
  source = "../../"
}

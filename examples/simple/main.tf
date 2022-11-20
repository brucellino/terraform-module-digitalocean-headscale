variable "vault_mount_path" {
  type        = string
  default     = "digitalocean"
  description = "Path in Vault to the Digital Ocean secrets"
}

variable "do_secret" {
  type        = string
  description = "Name of the secret in the vault mount for Digital Ocean tokens"
  default     = "tokens"
}
provider "vault" {}

data "vault_kv_secret_v2" "do" {
  mount = var.vault_mount_path
  name  = var.do_secret
}
provider "digitalocean" {
  token = data.vault_kv_secret_v2.do.data["terraform"]
}
module "example" {
  source = "../../"
}

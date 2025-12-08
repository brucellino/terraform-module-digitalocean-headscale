# Main definition
data "digitalocean_regions" "selected" {
  filter {
    key    = "slug"
    values = ["ams3"]
  }
}

data "digitalocean_vpc" "selected" {
  # name   = var.vpc_name
  region = data.digitalocean_regions.selected.regions[0].slug
}

# data "cloudflare_accounts" "hah" {}

# Create a CSR and generate a CA certificate
# resource "tls_private_key" "headscale" {
#   algorithm = "RSA"
# }

# resource "tls_cert_request" "headscale" {
#   # key_algorithm   = tls_private_key.headscale.algorithm
#   private_key_pem = tls_private_key.headscale.private_key_pem

#   subject {
#     common_name  = "headscale.hashiatho.me"
#     organization = "Hashi@Home"
#   }
# }


# resource "digitalocean_certificate" "headscale" {
#   name    = "headscale"
#   type    = "lets_encrypt"
#   domains = [digitalocean_domain.headscale.id]
# }

# Add an A record to the domain for www.example.com.
# resource "digitalocean_record" "headscale" {
#   domain = digitalocean_domain.headscale.id
#   type   = "A"
#   name   = "headscale"
#   value  = digitalocean_reserved_ip.public[0].ip_address
# }
# resource "cloudflare_custom_hostname" "headscale" {
#   zone_id  = "1127728daf6b916a5bba81889088c834"
#   hostname = "headscale.hashiatho.me"
# }

# resource "digitalocean_certificate" "headscale" {
#   name             = "headscale-lb"
#   type             = "custom"
#   private_key      = tls_private_key.headscale.private_key_pem
#   leaf_certificate = cloudflare_custom_hostname.headscale.id
#   # certificate_chain = cloudflare_origin_ca_certificate.headscale.id
# }

# resource "digitalocean_loadbalancer" "public" {
#   count       = var.lb_enabled ? 1 : 0
#   name        = "headsacale"
#   region      = data.digitalocean_regions.selected.regions[0].slug
#   droplet_tag = "headscale"

#   forwarding_rule {
#     entry_port     = 443
#     entry_protocol = "https"

#     target_port     = 80
#     target_protocol = "http"

#     certificate_name = digitalocean_certificate.headscale.name
#   }
# }

resource "digitalocean_reserved_ip" "public" {
  count  = var.lb_enabled ? 0 : 1
  region = data.digitalocean_regions.selected.regions[0].slug
}

resource "cloudflare_dns_record" "headscale" {
  name    = "headscale.hashiatho.me"
  ttl     = "3600"
  zone_id = "1127728daf6b916a5bba81889088c834"
  # value   = var.lb_enabled ? digitalocean_loadbalancer.public[0].ip : digitalocean_reserved_ip.public[0].ip_address
  content = digitalocean_reserved_ip.public[0].ip_address
  type    = "A"
  # ttl     = 3600
  proxied = true
}

data "digitalocean_ssh_key" "headscale" {
  name = "headscale"
}

resource "digitalocean_droplet" "headscale" {
  image    = "ubuntu-18-04-x64"
  name     = "headscale"
  region   = "ams3"
  size     = "s-1vcpu-1gb"
  vpc_uuid = data.digitalocean_vpc.selected.id
  ssh_keys = [data.digitalocean_ssh_key.headscale.id]
  # user_data = ""

}

resource "digitalocean_reserved_ip_assignment" "headscale" {
  ip_address = digitalocean_reserved_ip.public[0].ip_address
  droplet_id = digitalocean_droplet.headscale.id
}

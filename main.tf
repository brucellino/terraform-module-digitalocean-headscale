# Main definition
data "digitalocean_regions" "selected" {
  filter {
    key    = "slug"
    values = ["ams3"]
  }
  # filter {
  #   key    = "features"
  #   values = ["private_networking"]
  # }
}


# data "cloudflare_accounts" "hah" {}

# Create a CSR and generate a CA certificate
resource "tls_private_key" "headscale" {
  algorithm = "RSA"
}

resource "tls_cert_request" "headscale" {
  # key_algorithm   = tls_private_key.headscale.algorithm
  private_key_pem = tls_private_key.headscale.private_key_pem

  subject {
    common_name  = "headscale.hashiatho.me"
    organization = "Hashi@Home"
  }
}

resource "cloudflare_origin_ca_certificate" "headscale" {
  csr                = tls_cert_request.headscale.cert_request_pem
  hostnames          = ["headscale.hashiatho.me"]
  request_type       = "origin-rsa"
  requested_validity = 7
}

resource "digitalocean_certificate" "headscale" {
  name             = "headscale-lb"
  type             = "custom"
  private_key      = tls_private_key.headscale.private_key_pem
  leaf_certificate = cloudflare_origin_ca_certificate.headscale.certificate
  # certificate_chain = cloudflare_origin_ca_certificate.headscale.id
}

resource "digitalocean_loadbalancer" "public" {
  name        = "headsacale"
  region      = data.digitalocean_regions.selected.regions[0].slug
  droplet_tag = "headscale"

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.headscale.name
  }
}

# resource "cloudflare_record" "headscale_lb" {
#   name    = "headscale.hashiatho.me"
#   value   = digitalocean_loadbalancer.public.ip
#   type    = "A"
#   ttl     = 3600
# }

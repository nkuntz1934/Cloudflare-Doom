# ==========================
# Cloudflare IP address list
# ==========================
data "cloudflare_ip_ranges" "ip_ranges" {}
# ============
# Project name
# ============
resource "random_pet" "pet1" {
  length = 1
}
resource "random_pet" "pet2" {
  length = 1
}
resource "random_pet" "pet3" {
  length = 1
}
# =============
# Zone settings
# =============
resource "cloudflare_zone_settings_override" "encryption_mode" {
  zone_id = var.domain2_zone_id
  settings {
    security_level = "medium"
    ssl            = "strict"
    tls_1_3        = "on"
  }
}
# ============
# DNS A record
# ============
resource "cloudflare_record" "web" {
  zone_id = var.domain2_zone_id
  name    = random_pet.pet3.id
  value   = "192.0.2.1"  # Dummy IP for Load Balancer
  type    = "A"
  proxied = true
}
# ================
# Spectrum mapping
# ================
resource "cloudflare_spectrum_application" "ssh" {
  zone_id      = var.domain2_zone_id
  protocol     = "tcp/22"
  traffic_type = "direct"
  ip_firewall  = false
  edge_ips {  # Correct block syntax
    type         = "dynamic"
    connectivity = "all"
  }
  dns {
    type = "CNAME"
    name = "${random_pet.pet1.id}.${var.domain2}"
  }
  origin_direct = [
    "tcp://${aws_lightsail_static_ip_attachment.attachment[0].ip_address}:22"  # VM1
  ]
}
resource "cloudflare_spectrum_application" "ssh2" {
  zone_id      = var.domain2_zone_id
  protocol     = "tcp/22"
  traffic_type = "direct"
  ip_firewall  = false
  edge_ips {  # Correct block syntax
    type         = "dynamic"
    connectivity = "all"
  }
  dns {
    type = "CNAME"
    name = "${random_pet.pet2.id}.${var.domain2}"
  }
  origin_direct = [
    "tcp://${aws_lightsail_static_ip_attachment.attachment[1].ip_address}:22"  # VM2
  ]
}
# =================================
# Web server -- key and certificate
# =================================
resource "tls_private_key" "web" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "tls_cert_request" "web" {
  private_key_pem = tls_private_key.web.private_key_pem
  subject {
    common_name  = random_pet.pet3.id
    organization = var.domain2
  }
}
resource "cloudflare_origin_ca_certificate" "web" {
  csr                = tls_cert_request.web.cert_request_pem
  hostnames          = ["${random_pet.pet3.id}.${var.domain2}"]
  request_type       = "origin-rsa"
  requested_validity = 365
}
# ============
# WAF RULESETS
# ============
resource "cloudflare_ruleset" "example_waf" {
  zone_id     = var.domain2_zone_id
  name        = "Custom WAF Rules"
  description = "Terraform Managed WAF Rules"
  kind        = "zone"
  phase       = "http_request_firewall_custom"
  rules {
    action      = "managed_challenge"
    description = "Provide a managed challenge"
    enabled     = true
    expression  = "(http.request.uri.path contains \"/doom/\")"
  }
  rules {
    action      = "block"
    description = "block all requests from a specific country"
    enabled     = true
    expression  = "(ip.geoip.country in {\"RU\" \"CN\"})"
  }
}
# Added: Cloudflare Load Balancer Monitor
resource "cloudflare_load_balancer_monitor" "doom_monitor" {
  account_id      = var.account_id
  type            = "https"
  expected_codes  = "200"
  path            = "/doom/"
  interval        = 60
  timeout         = 5
  retries         = 2
  method          = "GET"
  description     = "Health check for Doom VMs"
  header {
    header = "Host"
    values = ["${random_pet.pet3.id}.${var.domain2}"]
  }
}
# Added: Cloudflare Load Balancer Pool
resource "cloudflare_load_balancer_pool" "doom_pool" {
  account_id = var.account_id
  name       = "doom-pool"
  monitor    = cloudflare_load_balancer_monitor.doom_monitor.id
  origins {
    name    = "vm1"
    address = aws_lightsail_static_ip_attachment.attachment[0].ip_address
    enabled = true
    weight  = 1.0
  }
  origins {
    name    = "vm2"
    address = aws_lightsail_static_ip_attachment.attachment[1].ip_address
    enabled = true
    weight  = 1.0
  }
}
resource "cloudflare_load_balancer" "doom_lb" {
  zone_id          = var.domain2_zone_id
  name             = "${random_pet.pet3.id}.${var.domain2}"
  fallback_pool_id = cloudflare_load_balancer_pool.doom_pool.id
  default_pool_ids = [cloudflare_load_balancer_pool.doom_pool.id]
  proxied          = true
  steering_policy  = "random"
}
# =======
# Outputs
# =======
output "cloudflare-web-cert" {
  value     = cloudflare_origin_ca_certificate.web.certificate
  sensitive = true
}
output "cloudflare-web-key" {
  value     = tls_private_key.web.private_key_pem
  sensitive = true
}
output "cloudflare-subdomain-1-ssh" { value = "${random_pet.pet1.id}.${var.domain2}" }
output "cloudflare-subdomain-2-ssh" { value = "${random_pet.pet2.id}.${var.domain2}" }
output "cloudflare-subdomain-3-web" { value = "${random_pet.pet3.id}.${var.domain2}" }
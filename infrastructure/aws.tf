# =========
# Variables
# =========
provider "aws" {
  region = var.location
}
# =========
# Random ID
# =========
resource "random_id" "projprefix" {
  byte_length = 4
}
# =========
# Static IP
# =========
resource "aws_lightsail_static_ip" "staticip" {
  count = 2  
  name  = "${random_id.projprefix.hex}-staticip-${count.index}"
}
# ====================
# Static IP attachment
# ====================
resource "aws_lightsail_static_ip_attachment" "attachment" {
  count          = 2  
  static_ip_name = aws_lightsail_static_ip.staticip[count.index].id
  instance_name  = aws_lightsail_instance.server[count.index].id
}
# =======
# SSH Key
# =======
resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_lightsail_key_pair" "sshkey" {
  name       = "${random_id.projprefix.hex}-ssh"
  public_key = tls_private_key.sshkey.public_key_openssh
}
# ========
# Firewall
# ========
resource "aws_lightsail_instance_public_ports" "firewall" {
  count         = 2  
  instance_name = aws_lightsail_instance.server[count.index].name
  port_info {
    cidrs             = data.cloudflare_ip_ranges.ip_ranges.ipv4_cidr_blocks
    cidr_list_aliases = ["lightsail-connect"]
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
  }
  port_info {
    cidrs     = data.cloudflare_ip_ranges.ip_ranges.ipv4_cidr_blocks
    protocol  = "udp"
    from_port = 51820
    to_port   = 51820
  }
  port_info {
    cidrs     = data.cloudflare_ip_ranges.ip_ranges.ipv4_cidr_blocks
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }
}
# ======
# Server
# ======
resource "aws_lightsail_instance" "server" {
  count             = 2  
  name              = "${random_id.projprefix.hex}-vm-${count.index}"
  availability_zone = "${var.location}a"
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "large_2_0"
  ip_address_type   = "ipv4"
  key_pair_name     = aws_lightsail_key_pair.sshkey.name
}
# =======
# Outputs
# =======
output "aws-server-username" { value = aws_lightsail_instance.server[0].username }  # Still works for both
output "aws-ssh-key" {
  value     = tls_private_key.sshkey.private_key_pem
  sensitive = true
}
output "aws-static-ip" { 
  value = aws_lightsail_static_ip_attachment.attachment[*].ip_address  # Changed: Array of IPs
}

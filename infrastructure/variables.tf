variable "location" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}
variable "domain1" {
  type        = string
  description = "Domain 1, VPN domain"
}
variable "domain1_zone_id" {
  type        = string
  description = "Domain 1 Zone ID"
}
variable "domain2" {
  type        = string
  description = "Domain 2, SSH/Web domain"
}
variable "domain2_zone_id" {
  type        = string
  description = "Domain 2 Zone ID"
}
variable "account_id" {
  type        = string
  description = "CF Account ID"
  sensitive   = true
}

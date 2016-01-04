variable "vpc_name" {
  description = "Name for the VPC containing the ECS cluster"
}

variable "zone_id" {
  description = "ID of Route53 hosted zone to create DNS names under"
}

variable "domain_name" {
  description = "Route53 domain name to create DNS names under"
}

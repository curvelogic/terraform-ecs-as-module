provider "aws" {
  region = "us-east-1"
}

module "ecs_cluster" {
  source = "github.com/roylines/terraform-ecs"
  instance_type = "t2.small"
  vpc = "${var.vpc_name}"
  domain_name = "${var.domain_name}"
  zone_id = "${var.zone_id}"
  availability-zones = "us-east-1b,us-east-1c,us-east-1d,us-east-1e"
}

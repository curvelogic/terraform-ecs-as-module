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

# Define a microservice using module abstracted out...
module "helloworld_service_2" {
  source = "./microservice"

  # All this stuff is just features of the cluster we need - none of
  # it changes:
  name_prefix = "${var.vpc_name}"
  vpc_id = "${module.ecs_cluster.vpc_id}"
  subnet_ids = "${module.ecs_cluster.subnet_ids}"
  domain_name = "${var.domain_name}"
  zone_id = "${var.zone_id}"
  ecs_cluster_id = "${module.ecs_cluster.ecs_cluster_id}"
  iam_role_arn = "${module.ecs_cluster.iam_role_arn}"

  # Features of the service itself:
  name = "helloworld2"
  docker_image = "tutum/hello-world"
  # Other values have defaults but could be overridden

  instance_port = 8081          # don't care but must be unique
}

# Just for convenience:
output "helloworld2_fqdn" {
  value = "${module.helloworld_service_2.service_fqdn}"
}

variable "name" {}
variable "name_prefix" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "container_port" { default = 80 }
variable "instance_port" {}
variable "load_balancer_port" { default = 80 }
variable "domain_name" {}
variable "zone_id" {}
variable "ecs_cluster_id" {}
variable "iam_role_arn" {}
variable "docker_image" {}
variable "container_cpu" { default = 512 }
variable "container_memory" { default = 256 }

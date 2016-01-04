resource "aws_security_group" "helloworld" {
  name = "${var.vpc_name}-helloworld-security-group"
  description = "Security group used for helloworld"
  vpc_id = "${module.ecs_cluster.vpc_id}" 
  ingress {
      from_port = 0 
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "helloworld" {
  name = "helloworld"
  subnets = ["${split(",",module.ecs_cluster.subnet_ids)}"]
  security_groups = ["${aws_security_group.helloworld.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
  
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }

  tags {
    Name = "${var.vpc_name}-helloworld"
  }
}

resource "aws_route53_record" "helloworld" {
  zone_id = "${var.zone_id}"
  name = "${var.vpc_name}-helloworld.${var.domain_name}"
  type = "A"

  alias {
    name = "${aws_elb.helloworld.dns_name}"
    zone_id = "${aws_elb.helloworld.zone_id}"
    evaluate_target_health =false 
  }
}

resource "aws_ecs_task_definition" "helloworld" {
  family = "${var.vpc_name}-helloworld"
  container_definitions = <<EOF
[
  {
    "name": "${var.vpc_name}-helloworld",
    "image": "tutum/hello-world",
    "cpu": 100,
    "memory": 512,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "helloworld" {
  name = "${var.vpc_name}-helloworld"
  cluster = "${module.ecs_cluster.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.helloworld.arn}"
  desired_count = 2
  iam_role = "${module.ecs_cluster.iam_role_arn}"

  load_balancer {
    elb_name = "${aws_elb.helloworld.id}"
    container_name = "${var.vpc_name}-helloworld"
    container_port = 80
  }
}

output "helloworld_fqdn" {
  value = "${aws_route53_record.helloworld.name}"
}

resource "aws_security_group" "service" {
  name = "${var.name_prefix}-${var.name}-service-security-group"
  description = "Security group used for service"
  vpc_id = "${var.vpc_id}" 
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

resource "aws_elb" "service" {
  name = "${var.name_prefix}-${var.name}-service"
  subnets = ["${split(",",var.subnet_ids)}"]
  security_groups = ["${aws_security_group.service.id}"]

  listener {
    instance_port = "${var.instance_port}"
    instance_protocol = "http"
    lb_port = "${var.load_balancer_port}"
    lb_protocol = "http"
  }

  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
  
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:${var.instance_port}/"
    interval = 30
  }

  tags {
    Name = "${var.name_prefix}-service"
  }
}

resource "aws_route53_record" "service" {
  zone_id = "${var.zone_id}"
  name = "${var.name_prefix}-${var.name}.${var.domain_name}"
  type = "A"

  alias {
    name = "${aws_elb.service.dns_name}"
    zone_id = "${aws_elb.service.zone_id}"
    evaluate_target_health =false 
  }
}

resource "aws_ecs_task_definition" "service" {
  family = "${var.name_prefix}-${var.name}-service"
  container_definitions = <<EOF
[
  {
    "name": "${var.name_prefix}-service",
    "image": "${var.docker_image}",
    "cpu": ${var.container_cpu},
    "memory": ${var.container_memory},
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.instance_port}
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "service" {
  name = "${var.name_prefix}-${var.name}-service"
  cluster = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.service.arn}"
  desired_count = 2
  iam_role = "${var.iam_role_arn}"

  load_balancer {
    elb_name = "${aws_elb.service.id}"
    container_name = "${var.name_prefix}-service"
    container_port = 80
  }
}

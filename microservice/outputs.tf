output "service_fqdn" {
  value = "${aws_route53_record.service.name}"
}

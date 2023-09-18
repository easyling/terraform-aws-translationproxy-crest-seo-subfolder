resource "aws_acm_certificate" "dynamic_cert" {
  validation_method = "DNS"
  domain_name       = var.domain

  tags = {
    product = "translationproxy",
    project = var.project,
    Name    = "${var.project}_managed_cert"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      subject_alternative_names,
      domain_name
    ]
  }
}

resource "aws_acm_certificate_validation" "dynamic_cert_validation" {
  certificate_arn = aws_acm_certificate.dynamic_cert.arn
  timeouts {
    create = "1m"
  }
}

output "cert_arn" {
  value = aws_acm_certificate.dynamic_cert[*].arn
}
output "cert_validation_options" {
  value = aws_acm_certificate.dynamic_cert[*].domain_validation_options
}

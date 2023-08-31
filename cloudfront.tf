resource "aws_cloudfront_distribution" "translation_at_prefix" {
  enabled = true
  aliases = [
    var.domain
  ]

  tags = {
    product = "translationproxy",
    project = var.project,
  }

  comment = "translationproxy_${var.project}"

  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]
    target_origin_id       = "origin"
    viewer_protocol_policy = "allow-all"

    cache_policy_id = aws_cloudfront_cache_policy.origin_policy.id
  }

  origin {
    domain_name = "origin-${lower(var.domain)}"
    origin_id   = "origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_read_timeout    = 60
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = [
        "TLSv1.1",
        "TLSv1.2"
      ]
    }
  }

  dynamic "origin" {
    for_each = var.prefix_to_locale
    iterator = prefix
    content {
      domain_name = lower("${prefix.value.locale}-${var.project}-j.${var.app_domain}")
      origin_id   = "translationproxy-${prefix.value.locale}"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_read_timeout    = 60
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = [
          "TLSv1.1",
          "TLSv1.2"
        ]
      }

      custom_header {
        name  = "X-TranslationProxy-Cache-Info"
        value = "disable"
      }
      custom_header {
        name  = "X-TranslationProxy-EnableDeepRoot"
        value = "true"
      }
      custom_header {
        name  = "X-TranslationProxy-AllowRobots"
        value = "true"
      }
      custom_header {
        name  = "X-TranslationProxy-ServingDomain"
        value = var.domain
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.prefix_to_locale
    iterator = prefix

    content {
      allowed_methods = [
        "DELETE",
        "GET",
        "HEAD",
        "OPTIONS",
        "PATCH",
        "POST",
        "PUT",
      ]
      cached_methods = [
        "GET",
        "HEAD",
      ]

      lambda_function_association {
        event_type   = "viewer-request"
        lambda_arn = aws_lambda_function.prerender_headers.qualified_arn
        include_body = true
      }

      lambda_function_association {
        event_type   = "origin-request"
        lambda_arn   = aws_lambda_function.prerender_redirect.qualified_arn
        include_body = true
      }

      viewer_protocol_policy = "allow-all"
      path_pattern           = prefix.value.target

      cache_policy_id = aws_cloudfront_cache_policy.caching_with_queries.id

      target_origin_id = prefix.value.origin ? "origin" : "translationproxy-${prefix.value.locale}"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.dynamic_cert.arn
    minimum_protocol_version = var.min_tls_version
    ssl_support_method       = "sni-only"
  }
}

output "domains_for_subdirectory_publishing" {
  value = [
    aws_cloudfront_distribution.translation_at_prefix.domain_name,
  ]
}

output "indirection" {
  value = "Create an A record with the name origin-${lower(var.domain)}, and point it at the original IP address of your server. This will free up the domain for pointing to Cloudfront eventually. You will not need to modify the server configuration otherwise!"
}

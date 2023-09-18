resource "aws_cloudfront_cache_policy" "caching_with_queries" {
  name = "translationproxy-${var.project}"

  comment = "Generic cache settings permitting query params"

  min_ttl     = var.caching_min_ttl
  default_ttl = var.caching_default_ttl
  max_ttl     = var.caching_max_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Origin",
          "Accept",
          "CloudFront-Forwarded-Proto",
          "Referer",
          "User-Agent",
          "X-TranslationProxy-CrawlingFor",
          "Accept-Language",
        ]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_cache_policy" "origin_policy" {
  name = "translationproxy-${var.project}_origin"

  comment = "Specialized cache policy for original server when hijacking the domain"

  min_ttl     = var.caching_min_ttl
  default_ttl = var.caching_default_ttl
  max_ttl     = var.caching_max_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Origin",
          "Accept",
          "CloudFront-Forwarded-Proto",
          "Referer",
          "User-Agent",
          "X-TranslationProxy-CrawlingFor",
          "Accept-Language",
          "Host",
        ]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

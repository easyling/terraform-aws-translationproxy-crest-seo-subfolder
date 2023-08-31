variable "domain" {
  description = "The original domain of the site. Used to create the route for the root and set configuration during subdirectory publishing"
  type        = string
}

variable "prefix_to_locale" {
  description = "List of published language objects. The two attributes are `target` for the path prefix, and `locale` for the locale code. MUST be given as list of two-by-two letter locales."
  type        = list(object({
    target = string
    locale = string
    origin = bool
  }))
}

variable "project" {
  description = "The project ID provided by the LSP"
  type        = string
}

variable "forward_query_strings" {
  description = "Forward query strings to Easyling. CAUTION: may decrease effectiveness of caching, and lead to greater traffic numbers."
  default     = false
  type        = bool
}

variable "app_domain" {
  description = "App domain provided by LSP"
  type        = string
}

variable "min_tls_version" {
  type        = string
  description = "Minimum TLS version spec for CloudFront to accept."
  default     = "TLSv1.2_2021"
}

variable "caching_min_ttl" {
  type = number
  description = "Minimum TTL for CloudFront cache in seconds"
  default = 1
}

variable "caching_default_ttl" {
  type = number
  description = "Default TTL for CloudFront cache in seconds, in the absence of other directives"
  default = 300
}

variable "caching_max_ttl" {
  type = number
  description = "Maximum TTL for CloudFront cache in seconds"
  default = 86400
}

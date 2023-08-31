# Translation Proxy Subdirectory Publishing Module

## Overview
This Terraform module enables the deployment and management of a Translation Proxy solution using AWS services. Specifically designed for publishing translations as subdirectories, the module manages components like caching policies, SSL/TLS certificates, Lambda functions for prerendering and redirection, and the IAM roles required for executing Lambda functions.

## Features
- **Caching Policies**: Configurable caching policies for CloudFront distributions.
- **SSL/TLS Certificates**: Dynamically provisions AWS ACM certificates with DNS validation.
- **Lambda Functions**:
   - Prerender Headers: Modifies request headers for supporting prerendering based on user agents.
   - Redirection: Redirects requests to `prerender.io` for improved JavaScript-heavy site rendering for search engine bots.
- **IAM Roles**: Sets up required IAM roles for Lambda function execution.

## Variables

- **domain**:
   - *Description*: The original domain of the site. Used to create the route for the root and set configuration during subdirectory publishing.
   - *Type*: string

- **prefix_to_locale**:
   - *Description*: List of published language objects. The attributes include `target` for the path prefix, `locale` for the locale code, and `origin` to determine if it's the original content.
   - *Type*: list(object({
     target = string
     locale = string
     origin = bool
     }))

- **project**:
   - *Description*: The project ID provided by the Language Service Provider (LSP).
   - *Type*: string

- **forward_query_strings**:
   - *Description*: Forward query strings to Easyling. CAUTION: may decrease the effectiveness of caching, leading to higher traffic numbers.
   - *Type*: bool
   - *Default*: false

- **app_domain**:
   - *Description*: App domain provided by the LSP.
   - *Type*: string

- **min_tls_version**:
   - *Description*: Minimum TLS version spec for CloudFront to accept.
   - *Type*: string
   - *Default*: "TLSv1.2_2021"

- **caching_min_ttl**:
   - *Description*: Minimum TTL for CloudFront cache in seconds.
   - *Type*: number
   - *Default*: 1

- **caching_default_ttl**:
   - *Description*: Default TTL for CloudFront cache in seconds, in the absence of other directives.
   - *Type*: number
   - *Default*: 300

- **caching_max_ttl**:
   - *Description*: Maximum TTL for CloudFront cache in seconds.
   - *Type*: number
   - *Default*: 86400

## Usage

```hcl
# Configure the AWS Provider
provider "aws" {
   region  = "us-east-1"
   profile = "example-profile"
}

module "translation-proxy-example" {
   project    = "example-project-id"
   app_domain = "example-app-domain.com"
   domain     = "example-domain.com"
   prefix_to_locale = [
      {
         target = "/example-path",
         origin = false,
         locale = "example-locale",
      }
   ]
}

output "cf_domain" {
   value = module.translation-proxy-example.domains_for_subdirectory_publishing
}
output "instructions" {
   value = module.translation-proxy-example.indirection
}
output "validation_record" {
   value = module.translation-proxy-example.cert_validation_options
}

```

## Outputs
- **cert_arn**: ARN of the provisioned dynamic certificate.
- **cert_validation_options**: Validation options for the dynamic certificate.

## Prerequisites
- AWS provider version 5.14.0 or newer.
- Relevant files (e.g., `prerender-headers.js` and `redirect.js`) should be present in the module directory.

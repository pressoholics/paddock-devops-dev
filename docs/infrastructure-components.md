# Infrastructure Components

# Table of Contents

- [Route 53](#route53)
- [S3](#s3)
- [CloudFront](#cloudfront)
- [Lambda](#lambda)
- [Web Application Firewall](#WebApplicationFirewall)
- [CloudTrail](#cloudtrail)
- [CloudWatch](#cloudwatch)
- [Trusted Advisor](#trustedadvisor)
- [Next steps](#nextsteps)

## Route 53

Uses AWS default domains

Explain more

## S3

### Environments

There are 3 buckets per environment:

- Origin
- Logs
- Terraform State

### Region

All the buckets will be located in US-East-1 (N. Virginia)

### Name convention

tri-[environment]-frontend-[role]

Environment:

- dev
- stage
- prod

Role:

- logs
- origin
- tfstate

### S3 Bucket logs

- Block all public access
- Enable AES-256 Default Encryption
- Tags:
  - env: [environment]
  - role: log

### S3 Bucket origin

- Block all public access
- Enable Versioning
- Enable server access logging, with origin-server-access as the prefix
- Enable AES-256 Default Encryption
- Enable Cloudtrail for writing and reading events
- Specific with the bucket policies (Least Privilege Permissions)
- Tags:
  - env: [environment]
  - role: origin

## CloudFront

There is one CloudFront distribution per environment, with one cache behaviours.

### Origin Settings

- Origin name: S3 Origin Bucket
- Restrict Bucket Access
- Origin Access Identity (Create a new one if there is not one created)
- Grant Read Permissions on Bucket

### Distribution Settings

- Use All Edge Locations for performance improvement
- Enable WAF
- Use a unique SSL certificate
- Use the latest version of TLS
- Enable Logging
  - S3 Bucket Log
  - Prefix: cloudfront
  - Cookie Logging: Off
- Enable IPv6
- Enable Distribution State
- Comment: Development/Staging/Production

### Default Cache Behaviour

- Path Pattern: Default
- Redirect HTTP to HTTPS
- Allow only GET and HEAD requests
- Cache Based on Selected Request Headers: None
- Object Caching: Use Origin Cache Headers
- Forward Cookies: None
- Query String Forwarding: None
- Smooth Streaming: No
- Restrict Viewer Access: No
- Compress Objects Automatically: Yes
- Security Headers Lambda@Edge
  - Event: Origin Response
  - Include Body: false
  - Cache: \*
- Basic Auth Lambda@Edge
  - Event: Viewer Request
  - Include Body: false
  - Cache: \*

Next steps:

- Include unsupported lambda on the infrastructure

## Lambda

### Basic-auth @Edge

Set basic auth for the website, source code located in the [jam3 lambda repo](https://github.com/Jam3/intern-lambdas/tree/master/%40edge-basic-auth)

#### Details

Permission: Lambda@Edge basic

### Security Headers @Edge

Set basic security for the website, source code located in the jam3 lambda repo

#### Details

Permission: Lambda@Edge basic

## Web Application Firewall

Have a WAF for every environment

### Name convention

tri-[environment]-wafacl

Environment

- dev
- stage
- Prod

### Details

Enable logging with Kinesis Firehose.

### Rules

- Managed rules
  - Amazon IP reputation list
  - Core rule set
  - Known bad inputs
- Custom
  - Create rules to block any unexpected query string (will provide with details once we know the URL sitemap and structure)
  - Create rules to restrict the size of the URI path (will provide with details once we know the URL sitemap)
  - Create rules to restrict what we are not expected in the URL path
  - Create rules to block requests with huge payloads

## CloudTrail

### Name convention

Tri-[environment]-frontend-[role]-trail

### Details

- Create trails for S3 read/write origin buckets
- Add tags
  - env: [environment]
  - role: log

## CloudWatch

- CloudFront alarm when requests are more than usual
- CloudFront alarm when 4xx or 5xx happens
- Alarms for Lambda@Edge based on Errors and Duration
- Alarms for Lambda@Edge based on the content of the logs using Metric Filters (our errors).
- Send alarms through SNS to tech leads
- Dashboard with a collection of metrics

## Trusted Advisor

Enable the basic version

## Next steps

Include AWS Config,

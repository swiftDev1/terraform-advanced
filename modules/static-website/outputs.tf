output "statc-website-endpoint" {
  value = aws_s3_bucket_website_configuration.static-website-configuration.website_endpoint
}
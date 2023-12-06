#Hosting a static website on S3

resource "aws_s3_bucket" "static-hosting-bucket" {
  bucket = var.bucket-name
  force_destroy = true


  tags = {
    Name        = "Static Website Bucket"
    Environment = "Dev"
  }
}

#Bucket policy allowing public access

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static-hosting-bucket.id
  policy = file("bucket-policy.json")
  
}

resource "aws_s3_bucket_website_configuration" "static-website-configuration" {
  bucket = aws_s3_bucket.static-hosting-bucket.id

  index_document {
    suffix = "index.html"
  }
}

#upload file to s3 bucket

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.static-hosting-bucket.bucket
  key    = "index.html"
  content = file("index.html")
  content_type = "text/html"

  

}

#Allow public access on the bucket

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.static-hosting-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
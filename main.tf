import {
  to = aws_instance.web-server
  id = "i-0566cc016a5e3d193"
}

resource "aws_instance" "web-server" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    tags = {
      "Name" = "Imported-Instance"
      "Terraform" = "true"
    }
  
}

resource "aws_s3_bucket" "terra-bucket" {
  bucket = var.bucket-name
  force_destroy = true
  
}
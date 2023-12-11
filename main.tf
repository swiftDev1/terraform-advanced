import {
  to = aws_instance.web-server
  id = "i-01f743c6bd8da6d1c"
}

resource "aws_instance" "web-server" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    tags = {
      "Name" = "Imported-Instance"
    }
  
}
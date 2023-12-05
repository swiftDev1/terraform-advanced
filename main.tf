module "ec2_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  for_each = toset(["web-server", "app-server"])

  name = each.key

  instance_type          = "t2.micro"
  key_name               = "dop-kp"
  monitoring             = false
  vpc_security_group_ids = ["sg-08cbdbed91e173c80"] #unsafe
  subnet_id              = "subnet-0d45318b8ce94b60d" #public subnet

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
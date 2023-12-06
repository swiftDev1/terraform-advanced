module "s3-website" {
  source = "./modules/static-website"
  bucket-name = var.bucket-name
  tags = var.tags

}
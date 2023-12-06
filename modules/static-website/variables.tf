variable "bucket-name" {
  type = string
  description = "A globally Unique name for your bucket"
}

variable "tags" {
  type = map(string)
  default = {}

}
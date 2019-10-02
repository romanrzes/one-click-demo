terraform {
  backend "s3" {
    bucket = "terraform-20190927145631752200000001"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

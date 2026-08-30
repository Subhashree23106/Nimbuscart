terraform {
  backend "s3" {
    bucket       = "nimbuscart-terraform-state-180840261930"
    key          = "nimbuscart/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

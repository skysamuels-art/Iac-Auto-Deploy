terraform {
  backend "s3" {
    bucket       = "samskys-tfstate-060255765406-us-west-2" # your existing bucket
    key          = "samskys-iac/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true # S3 native state locking (.tflock file)
  }
}
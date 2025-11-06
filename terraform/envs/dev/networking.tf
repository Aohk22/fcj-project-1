module "vpc" {
  source        = "../../modules/vpc"
  name          = "vpc_main"
  cidr_block    = "10.0.0.0/16"
  dns_support   = true
  dns_hostnames = true
}

module "subnet_pub_1" {
  source        = "../../modules/subnet"
  name          = "subnet_pub_1"
  az            = "ap-southeast-2a"
  cidr_block    = "10.0.0.0/24"
  vpc_id        = module.vpc.id
  map_public_ip = true
}

module "subnet_pub_2" {
  source        = "../../modules/subnet"
  name          = "subnet_pub_2"
  az            = "ap-southeast-2b"
  cidr_block    = "10.0.1.0/24"
  vpc_id        = module.vpc.id
  map_public_ip = true
}

module "subnet_prv_1" {
  source        = "../../modules/subnet"
  name          = "subnet_prv_1"
  az            = "ap-southeast-2a"
  cidr_block    = "10.0.2.0/24"
  vpc_id        = module.vpc.id
  map_public_ip = true
}

module "subnet_prv_2" {
  source        = "../../modules/subnet"
  name          = "subnet_prv_2"
  az            = "ap-southeast-2b"
  cidr_block    = "10.0.3.0/24"
  vpc_id        = module.vpc.id
  map_public_ip = true
}

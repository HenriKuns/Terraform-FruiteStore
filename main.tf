module "vpc_networking" {
  source = "./vpc_networking"
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_A_cidr = var.public_subnet_A_cidr
  public_subnet_B_cidr = var.public_subnet_B_cidr
  app_subnet_A_cidr = var.app_subnet_A_cidr
  app_subnet_B_cidr = var.app_subnet_B_cidr
  data_subnet_A_cidr = var.data_subnet_A_cidr
  data_subnet_B_cidr = var.data_subnet_B_cidr
  eip_association_address_A = var.eip_association_address_A
  eip_association_address_B = var.eip_association_address_B
  ec2_instance_type = var.ec2_instance_type
}
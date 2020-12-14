variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr_block" {}
variable "public_subnet_A_cidr" {}
variable "public_subnet_B_cidr" {}
variable "app_subnet_A_cidr" {}
variable "app_subnet_B_cidr" {}
variable "data_subnet_A_cidr" {}
variable "data_subnet_B_cidr" {}
variable "eip_association_address_A" {}
variable "eip_association_address_B" {}
variable "ec2_instance_type" {}
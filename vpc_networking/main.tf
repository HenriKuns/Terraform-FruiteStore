provider "aws" {
  region = var.region
}

resource "aws_vpc" "wp_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name="WP-VPC"
  }
}
resource "aws_subnet" "public_subnet_A" {
  cidr_block = var.public_subnet_A_cidr
  vpc_id = aws_vpc.wp_vpc.id
  availability_zone = "${var.region}a"

  tags = {
    Name="Public-Subnet-A"
  }
}
resource "aws_subnet" "public_subnet_B" {
  cidr_block = var.public_subnet_B_cidr
  vpc_id = aws_vpc.wp_vpc.id
  availability_zone = "${var.region}b"

  tags = {
    Name="Public-Subnet-B"
  }
}
resource "aws_subnet" "App_subnet_A" {
  cidr_block = var.app_subnet_A_cidr
  vpc_id = aws_vpc.wp_vpc.id
  availability_zone = "${var.region}a"

  tags = {
    Name="App-Subnet-A"
  }
}
resource "aws_subnet" "App_subnet_B" {
  cidr_block = var.app_subnet_B_cidr
  vpc_id = aws_vpc.wp_vpc.id
  availability_zone = "${var.region}b"

  tags = {
    Name="App-Subnet-B"
  }
}
resource "aws_subnet" "Data_subnet_A" {
  cidr_block = var.data_subnet_A_cidr
  vpc_id = aws_vpc.wp_vpc.id
  availability_zone = "${var.region}a"

  tags = {
    Name="Data-Subnet-A"
  }
}
resource "aws_subnet" "Data_subnet_B" {
  cidr_block = var.data_subnet_B_cidr
  vpc_id = aws_vpc.wp_vpc.id
  availability_zone = "${var.region}b"

  tags = {
    Name="Data-Subnet-B"
  }
}
resource "aws_route_table" "Public_route_table" {
  vpc_id = aws_vpc.wp_vpc.id
  tags = {
    Name="Public-Route-Table"
  }
}

resource "aws_route_table" "App_and_Data_A" {
  vpc_id = aws_vpc.wp_vpc.id
  tags = {
    Name="App_and_Data_A"
  }
}
resource "aws_route_table" "App_and_Data_B" {
  vpc_id = aws_vpc.wp_vpc.id
  tags = {
    Name="App_and_Data_B"
  }
}

resource "aws_route_table_association" "Public_Subnets_association_A" {
  route_table_id = aws_route_table.Public_route_table.id
  subnet_id = aws_subnet.public_subnet_A.id
}
resource "aws_route_table_association" "Public_Subnets_association_B" {
  route_table_id = aws_route_table.Public_route_table.id
  subnet_id = aws_subnet.public_subnet_B.id
}
resource "aws_route_table_association" "App_Data_Subnets_association_A" {
  route_table_id = aws_route_table.App_and_Data_A.id
  subnet_id =aws_subnet.App_subnet_A.id
}

resource "aws_route_table_association" "App_Data_Subnets_association_B" {
  route_table_id = aws_route_table.App_and_Data_B.id
  subnet_id = aws_subnet.App_subnet_B.id
}


resource "aws_eip" "elastic_ip_for_nat_gw_A" {
  vpc = true
  associate_with_private_ip = var.eip_association_address_A

  tags = {
    Name="Production-EIP-A"
  }
}
resource "aws_eip" "elastic_ip_for_nat_gw_B" {
  vpc = true
  associate_with_private_ip = var.eip_association_address_B

  tags = {
    Name="Production-EIP-B"
  }
}
resource "aws_nat_gateway" "nat_gateway_A" {
  allocation_id = aws_eip.elastic_ip_for_nat_gw_A.id
  subnet_id = aws_subnet.public_subnet_A.id

  tags = {
    Name="Production-NAT-GW-A"
  }
}
resource "aws_nat_gateway" "nat_gateway_B" {
  allocation_id = aws_eip.elastic_ip_for_nat_gw_B.id
  subnet_id = aws_subnet.public_subnet_B.id

  tags = {
    Name="Production-NAT-GW-B"
  }
}
resource "aws_route" "nat_gateway_route_A" {
  route_table_id = aws_route_table.App_and_Data_A.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_A.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "nat_gateway_route_B" {
  route_table_id = aws_route_table.App_and_Data_B.id
  nat_gateway_id = aws_nat_gateway.nat_gateway_B.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.wp_vpc.id

  tags = {
    Name="Production-IGW"
  }
}
resource "aws_route" "igw_route" {
  route_table_id = aws_route_table.Public_route_table.id
  gateway_id = aws_internet_gateway.internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_security_group" "ec2-security-group" {
  name = "Web_Temp"
  vpc_id = aws_vpc.wp_vpc.id

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ExternalWeb" {
  name = "ExternalWeb"
  vpc_id = aws_vpc.wp_vpc.id

  ingress {
    from_port = 80
    protocol = "TCP"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    protocol = "TCP"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }


}
resource "aws_security_group" "InternalWeb" {
  name = "INternal"
  vpc_id = aws_vpc.wp_vpc.id

  ingress {
    from_port = 80
    protocol = "TCP"
    to_port = 80
    security_groups = [aws_security_group.ExternalWeb.id]
  }

  ingress {
    from_port = 443
    protocol = "TCP"
    to_port = 443
    security_groups = [aws_security_group.ExternalWeb.id]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "test" {
  name               = "test-lb-tf"

  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ExternalWeb.id]
  subnets            = [aws_subnet.public_subnet_A.id, aws_subnet.public_subnet_B.id]
  #instances = [aws_instance.my-first-ec2-instance_A.id, aws_instance.my-first-ec2-instance_B.id]
  tags = {
    Environment = "production"
  }
}
resource "aws_lb_target_group" "test_target" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.wp_vpc.id
}
resource "aws_lb_listener" "test_listner" {
  load_balancer_arn = aws_lb.test.arn
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.test_target.arn
  }
}
resource "aws_lb_target_group_attachment" "test" {
  depends_on = [aws_lb.test]
  target_group_arn = aws_lb_target_group.test_target.arn
  target_id        = aws_instance.my-first-ec2-instance_A.id
  port             = 80
}
resource "aws_instance" "my-first-ec2-instance_A" {
  depends_on = [aws_lb.test]
  iam_instance_profile = "SSMRole"
  ami = "ami-0a07be880014c7b8e"
  instance_type = var.ec2_instance_type
  key_name = "ec2-key-aws"
  security_groups = [aws_security_group.InternalWeb.id]
  subnet_id = aws_subnet.App_subnet_A.id
  user_data = <<EOF
  #!/bin/bash
  yum update -y
  yum install -y docker
  service docker start
  docker pull bkimminich/juice-shop
  docker run -d -p 80:3000 bkimminich/juice-shop
  EOF

}
resource "aws_instance" "my-first-ec2-instance_B" {
  depends_on = [aws_lb.test]
  iam_instance_profile = "SSMRole"
  ami = "ami-0a07be880014c7b8e"
  instance_type = var.ec2_instance_type
  key_name = "ec2-key-aws"
  security_groups = [aws_security_group.InternalWeb.id]
  subnet_id = aws_subnet.App_subnet_B.id
  user_data = <<EOF
  #!/bin/bash
  yum update -y
  yum install -y docker
  service docker start
  docker pull bkimminich/juice-shop
  docker run -d -p 80:3000 bkimminich/juice-shop
  EOF
}


output "alb_address" {
  value = aws_lb.test.dns_name
}










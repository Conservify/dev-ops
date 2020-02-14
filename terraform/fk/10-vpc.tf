locals {
  top_cidr = "${lookup(var.workspace_to_network_map, terraform.workspace, "")}"
  network_a_cidr = "${lookup(var.workspace_to_network_a_map, terraform.workspace, "")}"
  network_b_cidr = "${lookup(var.workspace_to_network_b_map, terraform.workspace, "")}"
  network_c_cidr = "${lookup(var.workspace_to_network_c_map, terraform.workspace, "")}"
  network_e_cidr = "${lookup(var.workspace_to_network_e_map, terraform.workspace, "")}"
}

resource "aws_vpc" "fk" {
  cidr_block           = local.top_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
	Name = local.env
  }
}

resource "aws_internet_gateway" "fk" {
  vpc_id = aws_vpc.fk.id

  tags = {
	Name = local.env
  }
}

resource "aws_subnet" "fk-a" {
  vpc_id                  = aws_vpc.fk.id
  cidr_block              = local.network_a_cidr
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true

  tags = {
	Name = local.env
  }
}

resource "aws_subnet" "fk-b" {
  vpc_id                  = aws_vpc.fk.id
  cidr_block              = local.network_b_cidr
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = true

  tags = {
	Name = local.env
  }
}

resource "aws_subnet" "fk-c" {
  vpc_id                  = aws_vpc.fk.id
  cidr_block              = local.network_c_cidr
  availability_zone       = var.azs[2]
  map_public_ip_on_launch = true

  tags = {
	Name = local.env
  }
}

resource "aws_subnet" "fk-e" {
  vpc_id                  = aws_vpc.fk.id
  cidr_block              = local.network_e_cidr
  availability_zone       = var.azs[3]
  map_public_ip_on_launch = true

  tags = {
	Name = local.env
  }
}

resource "aws_route" "public_access" {
  route_table_id         = aws_vpc.fk.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fk.id
}

resource "aws_db_subnet_group" "fk" {
  name        = "fk"
  description = "fk"
  subnet_ids  = ["${aws_subnet.fk-a.id}", "${aws_subnet.fk-b.id}", "${aws_subnet.fk-c.id}", "${aws_subnet.fk-e.id}"]

  tags = {
	Name = local.env
  }
}

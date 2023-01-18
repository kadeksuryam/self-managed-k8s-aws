resource "aws_vpc" "k8s_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_k8s_subnet" {
  vpc_id            = aws_vpc.k8s_vpc.id
  count             = length(var.public_subnet_cidr_block)
  cidr_block        = element(var.public_subnet_cidr_block, count.index)
  availability_zone = element(var.availability_zones, count.index)
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
}

resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }
}

resource "aws_route" "pod_route" {
  count = 3
  route_table_id = aws_route_table.k8s_rt.id
  destination_cidr_block = "10.200.${count.index}.0/24"
  network_interface_id = element(aws_instance.k8s_worker[*].primary_network_interface_id, count.index)
}

resource "aws_route_table_association" "subnet_route" {
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = element(aws_subnet.public_k8s_subnet[*].id, count.index)
  route_table_id = aws_route_table.k8s_rt.id
}

resource "aws_eip" "k8s_address" {
}
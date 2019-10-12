resource "aws_vpc" "ddefault" {
  enable_dns_hostnames = true
  cidr_block           = "${var.vpc_cidr}"

  tags = {
    Name = "${var.aws_vpc_name}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.ddefault.id}"

  tags = {
    Name = "${var.aws_ig_name}"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.eu-central-1-public.id}"
  depends_on    = ["aws_internet_gateway.default"]


  tags = {
    Name = "${var.aws_nat_name}"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "eu-central-1-public" {
  vpc_id                  = "${aws_vpc.ddefault.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  availability_zone       = "${var.az}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.pub_sub_name}"
  }
}

resource "aws_route_table" "eu-central-1-public" {
  vpc_id = "${aws_vpc.ddefault.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags = {
    Name = "${var.pub_sub_name}"
  }
}

resource "aws_route_table_association" "eu-central-1-public" {
  subnet_id      = "${aws_subnet.eu-central-1-public.id}"
  route_table_id = "${aws_route_table.eu-central-1-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "eu-central-1-private" {
  vpc_id = "${aws_vpc.ddefault.id}"

  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "${var.az}b"

  tags = {
    Name = "${var.priv_sub_name}"
  }
}

resource "aws_route_table" "eu-central-1-private" {
  vpc_id = "${aws_vpc.ddefault.id}"

  route {
    cidr_block = "0.0.0.0/0"
    #gateway_id = "${aws_internet_gateway.default.id}"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags = {
    Name = "${var.priv_sub_name}"
  }
}

resource "aws_route_table_association" "eu-central-1-private" {
  subnet_id      = "${aws_subnet.eu-central-1-private.id}"
  route_table_id = "${aws_route_table.eu-central-1-private.id}"
}

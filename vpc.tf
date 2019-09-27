resource "aws_vpc" "default" {
    enable_dns_hostnames = true
    cidr_block = "${var.vpc_cidr}"
    tags = {
        Name = "terraform-aws-vpc"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"

    tags = {
    Name = "default"
  }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.eu-central-1-public.id}"
    depends_on = ["aws_internet_gateway.default"]


    tags = {
        Name = "VPC NAT"
    }
}

resource "aws_eip" "nat" {
    vpc = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "eu-central-1-public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "${var.az}a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public Subnet"
    }
}

resource "aws_route_table" "eu-central-1-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags = {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "eu-central-1-public" {
    subnet_id = "${aws_subnet.eu-central-1-public.id}"
    route_table_id = "${aws_route_table.eu-central-1-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "eu-central-1-private" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "${var.az}b"

    tags = {
        Name = "Private Subnet"
    }
}

resource "aws_route_table" "eu-central-1-private" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
#        nat_gateway_id = "${aws_nat_gateway.nat.id}"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags = {
        Name = "Private Subnet"
    }
}

resource "aws_route_table_association" "eu-central-1-private" {
    subnet_id = "${aws_subnet.eu-central-1-private.id}"
    route_table_id = "${aws_route_table.eu-central-1-private.id}"
}

/*
  Database Servers
*/
resource "aws_instance" "db_master" {
  ami                    = "${var.amis}"
  instance_type          = "${var.ins_type}"
  vpc_security_group_ids = ["${aws_security_group.db_instance.id}"]
  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.eu-central-1-private.id}"

  tags = {
    Name  = "db-master ${random_id.server.hex}"
    Group = "${var.db_serv_group}"
  }
}

resource "aws_instance" "db_slave" {
  ami                    = "${var.amis}"
  instance_type          = "${var.ins_type}"
  vpc_security_group_ids = ["${aws_security_group.db_instance.id}"]
  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.eu-central-1-private.id}"

  tags = {
    Name  = "db-slave ${random_id.server.hex}"
    Group = "${var.db_serv_group}"
  }
}

resource "aws_security_group" "db_instance" {
  name   = "${var.sec_group_db_name}"
  vpc_id = "${aws_vpc.ddefault.id}"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "${var.protocol_tcp}"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "${var.ssh_port}"
    to_port     = "${var.ssh_port}"
    protocol    = "${var.protocol_tcp}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "${var.protocol_tcp}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

output "elb_db_dns_name" {
  value = "${aws_elb.elb_db.dns_name}"
}

resource "aws_elb" "elb_db" {
  name = "elb_db"
  subnets = ["${aws_subnet.eu-central-1-private.id}"]

  listener {
    lb_port           = "${var.http_port}"
    lb_protocol       = "${var.protocol_http}"
    instance_port     = "${var.http_port}"
    instance_protocol = "${var.protocol_http}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.http_port}/"
  }
  instances = ["${aws_instance.db_master.id}", "${aws_instance.db_slave.id}"] 
}

resource "aws_security_group" "elb_db_sec" {
  name = "elb_db_sec"

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


/*
  Web Servers
*/

resource "aws_launch_configuration" "asg" {
  image_id        = "${var.amis}"
  instance_type   = "${var.ins_type}"
  security_groups = ["${aws_security_group.instance.id}"]
  key_name        = "${var.key_name}"
  name_prefix     = "Web-Server"
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = "${aws_launch_configuration.asg.id}"
  #availability_zones   = ["${var.az}a", "${var.az}b", "${var.az}c"]
  vpc_zone_identifier = ["${aws_subnet.eu-central-1-public.id}"]

  load_balancers    = ["${aws_elb.elb.name}"]
  health_check_type = "${var.health_check_type}"

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"

  tags = [
    {
      Name                = "web-server ${random_id.server.hex}"
      key                 = "${var.tag_key_asg}"
      value               = "${var.tag_value_asg}"
      propagate_at_launch = "${var.true_value}"
  }]
}

resource "aws_autoscaling_policy" "asg_pol" {
  name                   = "${var.asg_name}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  policy_type            = "${var.policy_type}"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "${var.predefined_metric_type}"
    }

    target_value = "${var.target_value}"
  }
}

resource "aws_security_group" "instance" {
  name   = "${var.sec_group_name_ins}"
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

  lifecycle {
    create_before_destroy = true
  }
}

output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

resource "aws_elb" "elb" {
  name = "${var.elb_name}"
  //availability_zones = ["${var.az}a", "${var.az}b", "${var.az}c"]
  subnets = ["${aws_subnet.eu-central-1-public.id}", "${aws_subnet.eu-central-1-private.id}"]

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
    target              = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb" {
  name = "${var.sec_group_elb_name}"

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

resource "aws_s3_bucket" "bucket_for_state" {
  acl    = "private"
  region = "${var.az}"

  versioning {
    enabled = "true"
  }

  tags = {
    "${var.tag_key1_s3}" = "${var.tag_value1_s3}",
    "${var.tag_key2_s3}" = "${var.tag_value2_s3}"
  }

}

resource "random_id" "server" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ami_id = "${var.amis}"
  }
  byte_length = 4
}

output "bucket_domain_name" {
  value = "${aws_s3_bucket.bucket_for_state.bucket_domain_name}"
}

/*resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.bucket_for_state.id}"
  key    = "terraform.tfstate"
  source = "/home/rmili/OneClick/terraform-aws-vpc/terraform.tfstate"
}
*/

/*terraform {
  backend "s3" {
    bucket = "terraform-20190927145631752200000001"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
*/

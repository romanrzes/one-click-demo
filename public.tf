/*
  Web Servers
*/

resource "aws_launch_configuration" "asg" {
  image_id = "ami-0ac05733838eabc06"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  key_name = "roma-terra"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = "${aws_launch_configuration.asg.id}"
  availability_zones = ["${var.az}a", "${var.az}b", "${var.az}c"]

  load_balancers = ["${aws_elb.elb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 5

  tags = [
   {
     key                 = "Group"
     value               = "Web"
     propagate_at_launch = true
   }]
}

resource "aws_autoscaling_policy" "asg_pol" {
  name = "asg_pol"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 80.0
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-instance"
  #vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

  ingress {
    from_port = "${var.http_port}"
    to_port = "${var.http_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
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
  name = "terraform-asg-example"
  availability_zones = ["${var.az}a", "${var.az}b", "${var.az}c"]

  listener {
    lb_port = "${var.http_port}"
    lb_protocol = "http"
    instance_port = "${var.http_port}"
    instance_protocol = "http"
  }

health_check {
  healthy_threshold = 2
  unhealthy_threshold = 2
  timeout = 3
  interval = 30
  target = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-elb"

  ingress {
    from_port = "${var.http_port}"
    to_port = "${var.http_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*resource "aws_instance" "jenkins" {
  ami = "ami-0ac05733838eabc06"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.jenkins.id}"]
  key_name = "/home/rmili/OneClickroma-terra"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get -y update
              sudo apt-get -y install openjdk-8-jre
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt-get -y update
              sudo apt-get -y install jenkins
              EOF

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_security_group" "jenkins" {
  name = "terraform-jenkins"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "${var.http_port}"
    to_port = "${var.http_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/

resource "aws_s3_bucket" "bucket_for_state" {
  acl    = "private"
  region = "${var.az}"

  versioning {
    enabled = "true"
  }

  tags = {
    Name        = "My bucket"
    Environment = "my-bucket-for-state"
  }
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

terraform {
  backend "s3" {
    bucket = "terraform-20190927145631752200000001"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

#variable "aws_access_key" {}
#variable "aws_secret_key" {}
#variable "aws_key_pair" {}
#variable "aws_key_name" {}

variable "aws_region" {
  description = "EC2 Region for the VPC"
  default     = "eu-central-1"
}

variable "amis" {
  description = "AMIs by region"
  default     = "ami-0ac05733838eabc06" # ubuntu 18.04 LTS

}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default     = "10.0.1.0/24"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

variable "http_port" {
  description = "HTTP Port"
  default     = 80
}

variable "ssh_port" {
  description = "SSH PORT"
  default     = 22
}

variable "az" {
  description = "az eu-central-1"
  default     = "eu-central-1"
}

variable "min_size" {
  description = "The minimum size of the auto scale group"
  default     = "2"
}

variable "max_size" {
  description = "The maximum size of the auto scale group"
  default     = "5"
}

variable "ins_type" {
  description = "Type of an instance"
  default     = "t2.micro"
}

variable "health_check_type" {
  description = "Health_check_type"
  default     = "ELB"
}

variable "key_name" {
  description = "Name of the key"
  default     = "roma-terra"
}

variable "jenkins_cred_url" {
  description = "Credentials for jenkins and url"
  default     = "--user $JENKINS_ID:$JENKINS_PASS  http://18.185.132.129:8080/job/Ansible_App_Up_And_Running/build?token=asdaff3124rtg423wfd"
}

variable "tag_key_asg" {
  description = "Name of the tag key"
  default     = "Group"
}

variable "tag_value_asg" {
  description = "Name of the tag value"
  default     = "Web"
}

variable "true_value" {
  description = "True value"
  default     = "True"
}

variable "asg_name" {
  description = "Name of the ASG"
  default     = "ASG"
}

variable "policy_type" {
  description = "Type of the policy"
  default     = "TargetTrackingScaling"
}

variable "predefined_metric_type" {
  description = "Metric type"
  default     = "ASGAverageCPUUtilization"
}

variable "target_value" {
  description = "Target value for ASGAverageCPUUtilization"
  default     = "80.0"
}

variable "sec_group_name_ins" {
  description = "Terraform instance name"
  default     = "terraform-instance"
}

variable "protocol_tcp" {
  description = "Tcp protocol"
  default     = "tcp"
}

variable "elb_name" {
  description = "Name of the ELB"
  default     = "terraform-asg-example"
}

variable "protocol_http" {
  description = "Http protocol"
  default     = "http"
}

variable "sec_group_elb_name" {
  description = "Name of the ELB security group"
  default     = "terraform-elb"
}

variable "s3bucket_name" {
  description = "Name of the ELB security group"
  default     = "terraform-elb"
}

variable "tag_key1_s3" {
  description = "Name of the tag key #1"
  default     = "Name"
}

variable "tag_value1_s3" {
  description = "Name of the tag value #1"
  default     = "My bucket"
}

variable "tag_key2_s3" {
  description = "Name of the tag key #2"
  default     = "Environment"
}

variable "tag_value2_s3" {
  description = "Name of the tag value #2"
  default     = "my-bucket-for-state"
}

variable "aws_vpc_name" {
  description = "Name of the vpc"
  default     = "terraform-aws-vpc"
}

variable "aws_ig_name" {
  description = "Name of the internet gateway"
  default     = "default"
}

variable "aws_nat_name" {
  description = "Name of the NAT"
  default     = "VPC NAT"
}

variable "priv_sub_name" {
  description = "Name of the private subnet"
  default     = "Private Subnet"
}

variable "pub_sub_name" {
  description = "Name of the public subnet"
  default     = "Public Subnet"
}

variable "db_master_name" {
  description = "Name of the Master instance"
  default     = "db_master"
}

variable "db_slave_name" {
  description = "Name of the Slave instance"
  default     = "db_slave"
}

variable "sec_group_db_name" {
  description = "Name of the security group for db"
  default     = "db"
}

variable "db_serv_group" {
  description = "Group of the db server"
  default     = "db-serv"
}

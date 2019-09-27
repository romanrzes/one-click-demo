#variable "aws_access_key" {}
#variable "aws_secret_key" {}
#variable "aws_key_pair" {}
#variable "aws_key_name" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "eu-central-1"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        eu-central-1 = "ami-0ac05733838eabc06" # ubuntu 18.04 LTS
    }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    default = 8080
}

variable "http_port" {
    description = "HTTP Port"
    default = 80
}

variable "ssh_port" {
    description = "SSH PORT"
    default = 22
}

variable "az" {
    description = "az eu-central-1"
    default = "eu-central-1"
}

# ---------- General ----------
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-west-2"
}

variable "project" {
  description = "Project name, used as a prefix on every resource"
  type        = string
  default     = "samskys-iac"
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
  default     = "dev"
}

# ---------- Networking ----------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "One public subnet per CIDR, spread across AZs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "One private (isolated, no internet route) subnet per CIDR"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# ---------- Security ----------
variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH (port 22). Use your IP/32 for real use."
  type        = string
  default     = "0.0.0.0/0"
}

variable "web_ports" {
  description = "Ports open to the internet for web traffic"
  type        = list(number)
  default     = [80, 443]
}

variable "ec2_managed_policy_arns" {
  description = "AWS managed policies attached to the EC2 role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

# ---------- Compute ----------
variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root disk size in GiB"
  type        = number
  default     = 8
}

variable "key_name" {
  description = "Name of an existing EC2 key pair in this region"
  type        = string
  default     = "1pu"
}

variable "ami_owner" {
  description = "AMI owner account ID (099720109477 = Canonical, publisher of Ubuntu)"
  type        = string
  default     = "099720109477"
}

variable "ami_name_filter" {
  description = "AMI name pattern (Ubuntu 24.04 LTS, x86_64)"
  type        = string
  default     = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
}

variable "ssh_user" {
  description = "Default login user for the AMI"
  type        = string
  default     = "ubuntu"
}

# ---------- Shared naming ----------
locals {
  name_prefix = "${var.project}-${var.environment}"
}
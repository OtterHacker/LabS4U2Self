variable "win_username" {
	description = "Windows Host default username to use"
	type = string
	default = "Administrator"
}

variable "win_password" {
	description = "Windows Host default password to use"
	type = string
  default = "password@123"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "test_lab"
}

variable "aws_region" {
  description = "AWS region to launch servers. Default to us-west-2"
  default     = "us-west-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC, e.g: 10.0.0.0/16"
  type = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  description = "A map of availability zones to CIDR blocks, which will be set up as subnets."
  type = map(string)
  default = {
    us-west-1a = "10.0.1.0/24"
    us-west-1b = "10.0.2.0/24"
  }
}

variable "ip_whitelist" {
  description = "A list of CIDRs that will be allowed to access the EC2 instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


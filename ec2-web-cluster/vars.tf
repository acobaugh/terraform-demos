data "aws_availability_zones" "all" {}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

variable "name" {
  default = "tf-ec2-cluster-demo"
}

variable "env" {
  default = "demo"
}

variable "region" {
	default = "us-east-1"
}

variable "amis" {
	type = "map"
	default = {
		us-east-2 = "ami-44bf9f21"
		us-east-1 = "ami-7b4d7900"
	}
}

variable "instance_type" {
	default = "t2.micro"
}

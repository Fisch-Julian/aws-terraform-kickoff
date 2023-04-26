variable "vpc_id" {
  description = "The VPC ID where the resources will be created."
}

variable "subnet_id" {
  description = "The Subnet in which the instance will be launched."
}

variable "key_name" {
  description = "The name of the key pair to be used for the EC2 instance."
}

variable "public_instance" {
  description = "Whether the instance should be accessible from the internet or not."
  default     = true
}

locals {
  userdata = file("${path.module}/userdata.sh")
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow inbound traffic on ports 80 and 22"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.public_instance ? ["0.0.0.0/0"] : ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.public_instance ? ["0.0.0.0/0"] : ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0b7fd829e7758b06d" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  subnet_id      = var.subnet_id

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_name

  user_data = base64encode(local.userdata)

  tags = {
    Name = "terraform-webserver"
  }
}

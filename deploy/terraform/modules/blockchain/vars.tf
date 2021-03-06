variable "key_name" { 
  default = "dev-eth-full-node-us-east-2" 
}

variable "region" {
  default = "us-east-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "amis" {
  type = "map"
  default = {
    "us-west-2" = "ami-79873901"
    "us-east-1" = "ami-b374d5a5"
    "us-east-2" = "ami-82f4dae7"
  }
}

variable "device_name" {
  default = "/dev/xvdg"
}

variable "vpc_id" {}
variable "subnet_id" {}
variable "num_nodes" {}
variable "working_environment" {}

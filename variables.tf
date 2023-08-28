variable "subnet_id_1" {
  type    = string
  default = "subnet-0eb1ecc0f95f88425"
}

variable "subnet_id_2" {
  type    = string
  default = "subnet-08da88830e6a5822c"
}

variable "bastion_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_key_name" {
  type    = string
  default = "Kubernetes"
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "cidr_block" {
  type    = string
  default = null
}

variable "bastion_name" {
  type    = string
  default = null
}

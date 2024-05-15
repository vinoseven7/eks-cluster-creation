variable "subnet_id_1" {
  type    = string
  default = null
}

variable "subnet_id_2" {
  type    = string
  default = null
}

variable "bastion_instance_type" {
  type    = string
  default = null
}


variable "ssh_key_name" {
  type    = string
  default = null
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

variable "cluster_name" {
  type    = string
  default = "Test"
}

variable "node_group_name" {
  type    = string
  default = null
}

variable "node_group_instance_type" {
  type    = list
  default = null
}

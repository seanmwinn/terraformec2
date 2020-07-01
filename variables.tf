variable "instance_type" {
  default = "t2.micro"
}

variable "region" {
  default = "us-east-1"
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "environment" {
  default = "staging"
}

variable "role" {
  default = "etcd3-test"
}

variable "dns" {
  type = map(string)

  default = {
    domain_name = "cilium.local"
  }
}

variable cidr_block {
  default = "10.0.0.0/16"
}

variable "cluster_size" {
  default = 3
}

variable "keypair_name" {
  default = "sean-keypair"
}

variable "ami" {
  type = map(string)

  default = {
    bastion = "ami-0a9e4c122b56383bf",
    etcd = "ami-0c40fbd26b9ac0da9"
  }
}

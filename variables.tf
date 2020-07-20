variable "ami" {
  type = map(string)

  default = {
    # ami for Bastion Host
    bastion = "ami-0a9e4c122b56383bf",
    # ami for etcd hosts
    etcd = "ami-0c40fbd26b9ac0da9"
  }
}

# Availability Zones to use, provided as a list
# ex: ["us-east-1a", "us-east-1b", "us-east-1c"]
variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Availability Zone for the bastion host
variable "bastion_az" {
  default = "us-east-1d"
}

# Instance type for bastion host
variable "bastion_instance_type" {
  default = "t2.micro"
}

# CIDR Blocks to use for ETCD and Kubernetes Clusters
# Number of blocks should be equal to the number of AZs defined
# Defined as a map
variable "cidr_blocks" {
  type = map(string)

  default = {
    etcd1   = "10.0.0.0/20"
    etcd2   = "10.0.16.0/20"
    etcd3   = "10.0.32.0/20"
    bastion = "10.0.48.0/20"
  }
}

# Number of etcd hosts, should be an odd number
variable "cluster_size" {
  default = 3
}

# Route 53 zone to use for hosting DNS names and load balancer name
variable "dns" {
  type = map(string)

  default = {
    domain_name = "cilium.local"
  }
}

# eks_ng variables should be set to zero initially upon creation
# after deleting the aws-node daemonset it is safe to increase these values
# and re-apply the terraform script
variable "eks_ng_desired_size" {
  default = "3"
}

variable "eks_ng_max_size" {
  default = "3"
}

variable "eks_ng_min_size" {
  default = "3"
}

# Environment name - used for naming the cluster
variable "environment" {
  default = "staging"
}

# First ethernet interface on ETCD instances
variable "etcd_ethernet_interface" {
  default = "eth0"
}

# Instance type to use for etcd servers
variable "etcd_instance_type" {
  default = "t2.micro"
}

# ETCD Version to install
variable "etcd_version" {
  default = "3.3.20"
}

# PEM format ssh private key
# To generate pem `openssl rsa -in ~/.ssh/id_rsa -outform pem > id_rsa.pem`
# This file should only be saved locally and not committed to a repository
# Define at runtime using `--var keypair_file=`
variable "keypair_file" {
  default = "change-me.pem"
}

# EC2 Keypair name used for accessing instances over SSH
# Define at runtime using `--var keypair_name=`
variable "keypair_name" {
  default = "change-me"
}

# AWS Region to create the cluster in
variable "region" {
  default = "us-east-1"
}

# Role - used for naming the cluster
variable "role" {
  default = "etcd3-test"
}

variable "worker_instance_type" {
  default = "m5.large"
}

variable "workers" {
  default = "3"
}

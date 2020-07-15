## Terraform ETCD cluster

These terraform scripts will create a functional ETCD cluster across multiple
Availability Zones on AWS.

To run, first customize the `variables.tf` file:

keypair_name must match an existing keypair on aws

keypair_file is generated using:
`$ openssl rsa -in ~/.ssh/id_rsa -outform pem > id_rsa.pem`

Other variables are self-explanatory.

Start the cluster using `terraform apply`

Destroy the cluster using `terraform destroy`

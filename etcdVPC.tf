# Create a VPC
resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"

  tags = {
      Name = "${var.environment}-${var.role}-eks-vpc"
  }
}

output "vpc-id" {
  value = aws_vpc.eks.id
}

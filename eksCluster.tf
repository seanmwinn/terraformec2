resource "aws_eks_cluster" "eks" {
  name     = "eks-cluster-${var.environment}-${var.role}"
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = [aws_subnet.etcd-subnet-1.id,
                  aws_subnet.etcd-subnet-2.id,
                  aws_subnet.etcd-subnet-3.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eksCluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eksCluster-AmazonEKSServicePolicy,
  ]
}

output "EKS_Endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks.certificate_authority.0.data
}

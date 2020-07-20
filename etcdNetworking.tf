# Create a new elastic IP to be used by the nat gateway
resource "aws_eip" "nat-eip" {
  vpc      = true

}

# Create NAT gateway so private subnets can route outside the VPC
resource "aws_nat_gateway" "etcd-nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = aws_subnet.bastion.id
  depends_on = [aws_internet_gateway.default]
}

# Create a route table object for the private etcd clusters to use the NAT gateway
resource "aws_route_table" "etcd-private" {
    vpc_id = aws_vpc.eks.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.etcd-nat-gw.id
    }
}

# Associate the aforementioned route table for the private subnet
resource "aws_route_table_association" "etcd-rta-1" {
  subnet_id = aws_subnet.etcd-subnet-1.id
  route_table_id = aws_route_table.etcd-private.id
}

resource "aws_route_table_association" "etcd-rta-2" {
  subnet_id = aws_subnet.etcd-subnet-2.id
  route_table_id = aws_route_table.etcd-private.id
}

resource "aws_route_table_association" "etcd-rta-3" {
  subnet_id = aws_subnet.etcd-subnet-3.id
  route_table_id = aws_route_table.etcd-private.id
}

# Create three subnets in the london AWS region
resource "aws_subnet" "etcd-subnet-1" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = var.cidr_blocks["etcd1"]
  availability_zone = var.azs[0]
  map_public_ip_on_launch = "false"

  tags = {
    Name = "${var.environment}-${var.role}-AZ1"
    "kubernetes.io/cluster/${var.environment}-${var.role}" = "shared"
  }
}

resource "aws_subnet" "etcd-subnet-2" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = var.cidr_blocks["etcd2"]
  availability_zone = var.azs[1]
  map_public_ip_on_launch = "false"

  tags = {
    Name = "${var.environment}-${var.role}-AZ2"
    "kubernetes.io/cluster/${var.environment}-${var.role}" = "shared"
  }
}

resource "aws_subnet" "etcd-subnet-3" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = var.cidr_blocks["etcd3"]
  availability_zone = var.azs[2]
  map_public_ip_on_launch = "false"

  tags = {
    Name = "${var.environment}-${var.role}-AZ3"
    "kubernetes.io/cluster/${var.environment}-${var.role}" = "shared"
  }
}

# Create a subnet for the Bastion host
resource "aws_subnet" "bastion" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = var.cidr_blocks["bastion"]
  availability_zone = var.bastion_az

  tags = {
    Name = "${var.environment}-${var.role}-Bastion"
  }
}

# Create network interfaces for each instance, connecting to the respective network
resource "aws_network_interface" "etcd1-eth0" {
  subnet_id   = aws_subnet.etcd-subnet-1.id
  security_groups = [aws_security_group.default.id]

  tags = {
    Name = "${var.environment}-${var.role}-etcd1-eni"
  }
}
resource "aws_network_interface" "etcd2-eth0" {
  subnet_id   = aws_subnet.etcd-subnet-2.id
  # private_ips = ["10.0.2.100"]
  security_groups = [aws_security_group.default.id]

  tags = {
    Name = "${var.environment}-${var.role}-etcd2-eni"
  }
}

resource "aws_network_interface" "etcd3-eth0" {
  subnet_id   = aws_subnet.etcd-subnet-3.id
  # private_ips = ["10.0.3.100"]
  security_groups = [aws_security_group.default.id]

  tags = {
    Name = "${var.environment}-${var.role}-etcd3-eni"
  }
}

# Create a application load balancer that spans the three subnets the EC2 instances reside
resource "aws_alb" "alb" {
  name            = "${var.environment}-${var.role}-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.default.id]
  subnets         = [aws_subnet.etcd-subnet-1.id, aws_subnet.etcd-subnet-2.id, aws_subnet.etcd-subnet-3.id]
  internal = true
}

# Create the target group for the ALB
resource "aws_alb_target_group" "group" {
  name     = "${var.environment}-${var.role}-target-group"
  port     = "2379"
  protocol = "HTTP"
  vpc_id   = aws_vpc.eks.id

  health_check {
  healthy_threshold   = 3
  unhealthy_threshold = 10
  timeout             = 5
  interval            = 10
  path                = "/version"
  port                = "2379"
  }
}

# Create a listener on the default ETCD listener port
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "2379"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}

# Attach the EC2 instances to the ALB
resource "aws_lb_target_group_attachment" "etc1" {
  target_group_arn = aws_alb_target_group.group.arn
  target_id        = aws_instance.etcd1.id
  port             = "2379"
}

resource "aws_lb_target_group_attachment" "etc2" {
  target_group_arn = aws_alb_target_group.group.arn
  target_id        = aws_instance.etcd2.id
  port             = "2379"
}

resource "aws_lb_target_group_attachment" "etc3" {
  target_group_arn = aws_alb_target_group.group.arn
  target_id        = aws_instance.etcd3.id
  port             = "2379"
}

# Create a IGW for the VPC
resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.eks.id
}

#Add route out for bastion subnet
resource "aws_route_table" "default" {
    vpc_id = aws_vpc.eks.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }
}

resource "aws_route_table_association" "bastion" {
  subnet_id      = aws_subnet.bastion.id
  route_table_id = aws_route_table.default.id
}

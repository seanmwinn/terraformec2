resource "aws_route53_zone" "etcd" {
  name          = "${var.environment}.${var.dns["domain_name"]}"
  vpc {
    vpc_id        = aws_vpc.eks.id
  }
}

resource "aws_route53_record" "etcd1" {
  zone_id = aws_route53_zone.etcd.id
  name    = "etcd1.${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.etcd1.private_ip]
}

resource "aws_route53_record" "etcd2" {
  zone_id = aws_route53_zone.etcd.id
  name    = "etcd2.${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.etcd2.private_ip]
}

resource "aws_route53_record" "etcd3" {
  zone_id = aws_route53_zone.etcd.id
  name    = "etcd3.${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.etcd3.private_ip]
}

resource "aws_route53_zone" "etcd" {
  name          = "${var.environment}.${var.dns["domain_name"]}"
  vpc {
    vpc_id        = "${aws_vpc.etcd.id}"
  }
}

resource "aws_route53_record" "peers" {
  count   = "${var.cluster_size}"
  zone_id = "${aws_route53_zone.etcd.id}"
  name    = "peer-${count.index}.${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
  type    = "A"
  ttl     = "1"
  records = ["10.0.${count.index}.100"]
}

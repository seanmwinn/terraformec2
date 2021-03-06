# Load the template file and replace the discovery URL with the response we get from the discovery URL
data "template_file" "service_template" {
  template = file("./deployetcd.tpl")


  vars = {
    discoveryURL = data.http.etcd-join.body
    etcd_interface = var.etcd_ethernet_interface
    etcd_version = var.etcd_version
  }
}

# Take the rendered script and place it in the local dir as "script.sh"
resource "local_file" "template" {
  content  = data.template_file.service_template.rendered
  filename = "${var.environment}-${var.role}-script.sh"
}

# Query the discovery url with the size of the cluster. The response will be a unique code we ned to parse into the bootstrap script (script.sh)
data "http" "etcd-join" {
  url = "https://discovery.etcd.io/new?size=${var.cluster_size}"
}

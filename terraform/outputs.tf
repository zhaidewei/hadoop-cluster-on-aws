output "cluster_public_dns" {
  value = "${aws_instance.cluster.*.public_dns}"
}

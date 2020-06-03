output "cluster_public_dns" {
  value = "${aws_instance.cluster.*.public_dns}"
}

output "cluster_route_table" {
  # to use in /etc/hosts inside cluster
  value = [

    "${element(aws_instance.cluster.*.private_ip, 0)} node01",
    "${element(aws_instance.cluster.*.private_ip, 1)} node02",
    "${element(aws_instance.cluster.*.private_ip, 2)} node03",
  ]
}

output "local_route_table" {
  # to use in /etc/hosts at local PC
  value = [

    "${element(aws_instance.cluster.*.public_ip, 0)} ${element(aws_instance.cluster.*.private_dns, 0)} node01",
    "${element(aws_instance.cluster.*.public_ip, 1)} ${element(aws_instance.cluster.*.private_dns, 1)} node02",
    "${element(aws_instance.cluster.*.public_ip, 2)} ${element(aws_instance.cluster.*.private_dns, 2)} node03",
  ]
}

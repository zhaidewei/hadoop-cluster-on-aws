output "node01_public_ip" {
  value = "${aws_instance.node01.public_ip}"
}

output "node02_public_ip" {
    value = "${aws_instance.node02.public_ip}"
}

output "node03_public_ip" {
    value = "${aws_instance.node03.public_ip}"
}

output "node01_public_dns" {
  value = "${aws_instance.node01.public_dns}"
}

output "node02_public_dns" {
    value = "${aws_instance.node02.public_dns}"
}

output "node03_public_dns" {
    value = "${aws_instance.node03.public_dns}"
}



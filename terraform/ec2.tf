provider "aws" {
  region                  = "eu-west-1"
  version                 = "~> 2.19.0"
  shared_credentials_file = "/Users/deweizhai/.aws/credentials"
  profile                 = "default"
}

# cluster
resource "aws_instance" "cluster" {

  count = 3

  # Instance sizing and config
  instance_type = var.instance_type
  ami           = var.aws_ami

  # Authentication
  key_name = var.key_pair

  # Network / security config
  associate_public_ip_address = true
  security_groups             = ["hadoop_cluster", "Remote Access Hadoop Cluster"]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  # extra block devices
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 8
    volume_type = "gp2"
  }

  user_data = var.initialize_script
}

resource "null_resource" "etc_hosts_file" {
  triggers = {
    cluster_instance_ids = "${join(",", aws_instance.cluster.*.id)}"
  }

  provisioner "local-exec" {
    # Used for easy update the /etc/hosts file in instances
    command = "echo -e \"${element(aws_instance.cluster.*.private_ip, 0)} ${element(aws_instance.cluster.*.private_dns, 0)} node01\n${element(aws_instance.cluster.*.private_ip, 1)} ${element(aws_instance.cluster.*.private_dns, 1)} node02\n${element(aws_instance.cluster.*.private_ip, 2)} ${element(aws_instance.cluster.*.private_dns, 2)} node03\""
  }
}

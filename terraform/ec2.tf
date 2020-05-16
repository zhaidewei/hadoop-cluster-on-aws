provider "aws" {
    region                  = "eu-west-1"
    version                 = "~> 2.19.0"
    shared_credentials_file = "/Users/deweizhai/.aws/credentials"
    profile                 = "dewei"
}

# masternode
resource "aws_instance" "node01" {

  # Instance sizing and config
  instance_type = var.master_instance_type
  ami           = var.aws_ami

  # Authentication
  key_name = var.keyPair

  # Network / security config
  associate_public_ip_address = true
  security_groups = ["hadoop_cluster", "Remote Access Hadoop Cluster"]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  # extra block devices
  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_size = 8
    volume_type = "gp2"
  }

}

resource "aws_instance" "node02" {

  # Instance sizing and config
  instance_type = var.master_instance_type
  ami           = var.aws_ami

  # Authentication
  key_name = var.keyPair

  # Network / security config
  associate_public_ip_address = true
  security_groups = ["hadoop_cluster", "Remote Access Hadoop Cluster"]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  # extra block devices
  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_size = 8
    volume_type = "gp2"
  }
}

resource "aws_instance" "node03" {

  # Instance sizing and config
  instance_type = var.master_instance_type
  ami           = var.aws_ami

  # Authentication
  key_name = var.keyPair

  # Network / security config
  associate_public_ip_address = true
  security_groups = ["hadoop_cluster", "Remote Access Hadoop Cluster"]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  # extra block devices
  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_size = 8
    volume_type = "gp2"
  }

}

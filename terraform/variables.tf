

variable "master_instance_type" {
  default = "t2.medium"
}

variable "slave_instance_type" {
  default = "t2.medium"
}

variable "aws_ami" {
  # CentOS 7 (x86_64) - with Updates HVM
  # https://aws.amazon.com/marketplace/pp/B00O7WM7QW?ref=cns_srchrow
  default = "ami-0b850cf02cc00fdc8"
}

variable "keyPair" {
    default = "deweiKeyPairEc2"
}

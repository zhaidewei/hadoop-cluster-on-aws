# hadoop-cluster-on-aws

Setup my own Hadoop cluster on AWS Ec2

## Terraform

Terraform v0.12.19.

Use the `shared_credentials_file` to provide TF the credential.

```terraform
provider "aws" {
  region                  = "eu-west-1"
  version                 = "~> 2.19.0"
  shared_credentials_file = "/Users/deweizhai/.aws/credentials"
  profile                 = "default"
}
```

### Use terraform output to show public DNS

```bash
terraform output
```

## Build process

Launch target is a 3 node cluster which unmanaged CDH 5.12 will be deployed upon.

## SSH from local

key pair is an existing one from my AWS account, I have the pem file stored locally.

Make below config at local `~/.ssh/config`, so that a simple `ssh <public_dnsname>` will allow me successfully ssh from local.

```bash
Host *eu-west-1.compute.amazonaws.com
User centos
Port 22
IdentityFile ~/Documents/500-秘密和隐私/deweiKeyPairEc2.pem
```

## SSH between nodes in cluster

Two configs at each node is needed, we do it in the boostrap script (at tf var `initialize_script`)

1. Allow Pubkey SSH
2. Use same id_rsa key and pub key at every node and use the pub key as authorized keys

One work is also needed to update the local route table `/etc/hosts`


This however is still a manual work.

1. Run `terraform output` shows the content to be added.

```bash
cluster_route_table = [
  "172.31.44.245 ip-172-31-44-245.eu-west-1.compute.internal node01",
  "172.31.32.68 ip-172-31-32-68.eu-west-1.compute.internal node02",
  "172.31.44.127 ip-172-31-44-127.eu-west-1.compute.internal node03",
]
```

2. Use root user to run the this command to update `/etc/hosts` on every node.

```bash
echo "172.31.44.245 ip-172-31-44-245.eu-west-1.compute.internal node01" >> /etc/hosts
echo "172.31.32.68 ip-172-31-32-68.eu-west-1.compute.internal node02" >> /etc/hosts
echo "172.31.44.127 ip-172-31-44-127.eu-west-1.compute.internal node03" >> /etc/hosts
```

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

Public DNS is used for SSH.


## Build process

Launch target is a 3 node cluster which unmanaged CDH 5.12 will be deployed upon.

### Step1 Spin up cluster

```bash
terraform init
terraform plan
terraform apply
```

### Step2 Manual works

1. Config /etc/hosts, see [this](#ssh-between-nodes-in-cluster)
2. **Onetime** Run `hdfs namenode format` as user hadoop.
3. **Onetime** After HDFS is running, run below command to create staging dirs for yarn.

```bash
hdfs dfs -mkdir -p /user/history
hdfs dfs -chmod -R 1777 /user/history
hdfs dfs -chown mapred:hadoop /user/history

hdfs dfs -mkdir /tmp
hdfs dfs -chmod -R 1777 /tmp
```

4. Only after reboot & optional, run `mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-04d838ce.efs.eu-west-1.amazonaws.com:/ /efs` to mount nfs.


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

## Synchronization config files to cluster

`config` files are included in this repo under `configs` dir.

User `hadoop`'s `id_rsa.pub` has been added to my github.com trusted ssh keys.

So with hadoop user, run `git clone` in bootstrap will download the whole repo towards the `/efs` folder. This folder is mounted to an AWS EFS (a nfs) device so it will persist.

That efs is not managed by Terraform and I used it as a local software installation cache.

Eevery time when I updated any configs, I need to run `git pull` at the `/efs` path.

Then running this script can distribute the files to target:

```bash
export cdh=hadoop-2.6.0-cdh5.14.4
for file in hadoop-env.sh core-site.xml hdfs-site.xml mapred-site.xml yarn-site.xml slaves yarn-env.sh
do
cp /efs/hadoop-cluster-on-aws/configs/$file /kkb/install/$cdh/etc/hadoop/$file
done
chmod 755 /kkb/install/$cdh/etc/hadoop/*.sh
```

## Synchronization jar files

This cluster is used for learning hadoop purpose, so being able to run jar files is important.

Development and packaging job is done at my local pc with IDEA.

I use a script to sync between local and hadoop home in the namenode node.

```bash
#!/usr/local/bin/bash

rsync -va --delete --exclude ".git" --exclude ".idea" $1  $2:/home/hadoop
```

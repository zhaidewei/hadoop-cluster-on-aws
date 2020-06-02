

variable "instance_type" {
  default = "t2.medium"
}

variable "aws_ami" {
  # CentOS 7 (x86_64) - with Updates HVM
  # https://aws.amazon.com/marketplace/pp/B00O7WM7QW?ref=cns_srchrow
  default = "ami-0b850cf02cc00fdc8"
}

variable "key_pair" {
  default = "deweiKeyPairEc2"
}

variable "initialize_script" {
  default = <<EOF
#!/bin/bash

yum install -y nfs-utils
yum install -y ntp
yum install -y wget
yum install -y openssl-devel
yum install -y git

# Users
useradd hadoop
echo "hadoop:123456" | sudo chpasswd
echo "hadoop ALL=(ALL)    ALL" >> /etc/sudoers
useradd hdfs
usermod -a -G hadoop hdfs

sudo useradd mapred
sudo usermod -a -G hadoop mapred

sudo useradd yarn
sudo usermod -a -G hadoop yarn


# cdh version
export cdh=hadoop-2.6.0-cdh5.14.4

# dirs

mkdir /efs

mkdir /kkb

# nfs mount
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-04d838ce.efs.eu-west-1.amazonaws.com:/ /efs
ln -s /efs /kkb/soft

mkdir  /kkb/install
tar -xzvf /kkb/soft/$cdh.tar.gz -C /kkb/install/

# data volume mounts
mkfs -t xfs /dev/xvdb
mkdir -p /kkb/install/$cdh/hadoopDatas
mount /dev/xvdb /kkb/install/$cdh/hadoopDatas
# Config auto mount
echo -e "UUID=$(blkid /dev/xvdb -o value | head -n 1) /kkb/install/$cdh/hadoopDatas xfs defaults,nofail 0 2" >> /etc/fstab


mkdir -p /kkb/install/$cdh/hadoopDatas/tempDatas
mkdir -p /kkb/install/$cdh/hadoopDatas/namenodeDatas
mkdir -p /kkb/install/$cdh/hadoopDatas/datanodeDatas
mkdir -p /kkb/install/$cdh/hadoopDatas/dfs/nn/edits
mkdir -p /kkb/install/$cdh/hadoopDatas/dfs/snn/name
mkdir -p /kkb/install/$cdh/hadoopDatas/dfs/nn/snn/edits

chown -R hadoop:hadoop /kkb


# Sysconfig
sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config
systemctl restart sshd.service
systemctl start ntpd
systemctl enable ntpd
ntpdate -u 169.254.169.123 # aws ntp server
hwclock --systohc
setenforce 0

# Installs Oracle JDK from NFS
rpm -ivh /efs/jdk-8u181-linux-x64.rpm

# Update /etc/profile
echo -e "export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))" >> /etc/profile
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
echo "export CLASSPATH=.:\$JAVA_HOME/jre/lib:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar" >> /etc/profile

echo -e "export HADOOP_HOME=/kkb/install/$cdh" >> /etc/profile
echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> /etc/profile

echo "export MAVEN_HOME=/kkb/compile/apache-maven-3.0.5" >> /etc/profile
echo "export MAVEN_OPTS=\"-Xms4096m -Xmx4096m\"" >> /etc/profile
echo "export PATH=\$PATH:\$MAVEN_HOME/bin" >> /etc/profile

# Allow SSH to each others
sudo su hadoop
mkdir /home/hadoop/.ssh
echo -e "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAubchAqqikq/TB9q0HjYc+5fzVl5nVC7kJkIvh/x1mTzoxX9k\nv9Q8X/CGsipvYzv0X6ToUlbp7hcO7078BjDp8P3zvSyxaUGWgg7+L5TvLBgb/FGX\nxNdkFdCDj5sqZasBbNLZwwlX9khWphz4BY/547fu8WxtBeTO5ItDvZNsdMJsPiDS\n+iK9pkP9iLMIVrJ0UPZ5vbku1/9WHn4zZToYZra8bonq5wN+FkurRgsjuU5FobJ3\n3UkNAbuIaPqc5CNrBcjC4XffFgg/TSxObLEFjrmjMShN2577b8NIX8syrlp4Q2t4\nzChn3p79XVdJGnh/ra0prm3lJIyoMbxVPFOTLwIDAQABAoIBADy4t75bdFRp0KIc\nzA+kuc05XYK70yUfP9GSil/4F6tG0wTgJlziU+s6hY/zeAAGNlyfWqaxbENAns14\nEcckbxkwr2UHG+rCWyejJ1D/bUQJjfzt4KWnlz3as2lc3nvnccvXFQREJdKMzGf7\nyMxoyte96A5f2TW4Hj1zm258qVVzPaWf/jPG7lyFLE7iIeMx+jR6OGr7eU28l3Aa\n7MtleuqgU+6ybeoKPzIitf0FpthKPwNR7G22jl3Detm8I2lwqrlM0V9jEjJspEcq\nHxiT7YHSdnR1zUlHQwRkxYLlQo4Lo49/rSO5aKbcGwtciEfom8r3s+Zbrkdi4Jbn\nkBZHKqECgYEA4vwdctHhU1Iv6ebGnxwFjOFeGQ6C/ilTtPsIZRGo0lyA2ZMCMcj5\neU+vSalHZAHSoLLZI0+u53mGVfNRoBnDAusUBBwIzzX/OCVJkL5CDa/IqNsQt9PH\nzbpupkOA58jdYKUMTNiQJwYIBaPvGNoWgw7Yue8UBEQBYIUfVq05daUCgYEA0XSB\nZPyQVeG6ObgFJ+9c/GKv+WZ6z2tcw+t45sQg8b2djjBfku3d8YNBP4rxrLjCniDf\nKdXGKIn0MrtY1Vi8ZYAR2hp9tsfSFlrMilMrj/V/YfQTdJcN8KOzChneIZFzg/bW\nG7X3NBVd7xS8G77Fb+PXde9uRrlwkRphXfgyVUMCgYBZLVwUhEjWh2+zoatfT48O\nrmxdw8nLOUldzVKbArklDJrC4HL4RFFfS+M+OXeG3wB1ik6tBN1eq+wPUK09DWIE\nf385rhn37ur6kAu7BkTFQ86+KHMFBft15E0cnWDDr7LqCW4vstXPvxrfvGxvgx9d\nFjQnuLpQgrdXyHVrhFsS0QKBgBttjDwzLptwcbh5NoOiPqT2L2ETYGWlA4LMZQqj\nCEVftTAXeYx+BaBItdSiVz9s+l9GorKRwd8xIX87NUjK0/DesnfDHE9BH2u5/Cro\n9T1mwoWLNrj/xt2KMjnSZVoz99KCEkuSqopxedmC95cShjw+s8pHzkMIqYr2z2VE\nySKNAoGBANG9qhvUh/HR0jUNggoS+WNdTFOMvIQxhXKs1EElLrKFGkRhg86gYNhO\nSz+x3Dp3oPK00VdGZdj/B2lCErIVmaKBmLdXdGmTHY84eT4gKbY+R0kJTnZGAJso\niSZHyxdjfruhIxTHPO68ClIc6dtWiJHfzRAPuBFl0YIltPeqGceo\n-----END RSA PRIVATE KEY-----\n" > /home/hadoop/.ssh/id_rsa
echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5tyECqqKSr9MH2rQeNhz7l/NWXmdULuQmQi+H/HWZPOjFf2S/1Dxf8IayKm9jO/RfpOhSVunuFw7vTvwGMOnw/fO9LLFpQZaCDv4vlO8sGBv8UZfE12QV0IOPmyplqwFs0tnDCVf2SFamHPgFj/njt+7xbG0F5M7ki0O9k2x0wmw+INL6Ir2mQ/2IswhWsnRQ9nm9uS7X/1YefjNlOhhmtrxuiernA34WS6tGCyO5TkWhsnfdSQ0Bu4ho+pzkI2sFyMLhd98WCD9NLE5ssQWOuaMxKE3bnvtvw0hfyzKuWnhDa3jMKGfenv1dV0kaeH+trSmubeUkjKgxvFU8U5Mv hadoop@ip-172-31-35-116.eu-west-1.compute.internal" > /home/hadoop/.ssh/id_rsa.pub
cp /home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/authorized_keys
# Pubkey used when creating EC2
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9Iq1m4CnhNt9jZMLndGu6fMTy5X1skFwbzKcipb37jMX6tELZ+LaB8TOW8MjYyD9nuiA48cOkit8i6rLtGv17wvG0YzGlY9NRyafBTGz1z+eh81iCtRs18U2czbaiW3q5RLiw/NQVEYYu0twATKKnu5IUZNWNYrhoZmNIJsH3ysUALJsxaym5AP9QZh0Z+D76/lz+ab1fgPRIeBDegizckmTRQuO2YZ9UWLDlrX6eDPepoS+H8MwUpI7aoMpx4R3ClxuZm2CCkZlIkb1HOmgMbaIUgwCOPeqxZpFKkqb6y5VzEKxl+LU9iOmy8GolfYcrDqBmQXyktJQneXNzYpKb deweiKeyPairEc2" >> /home/hadoop/.ssh/authorized_keys
chmod 700 /home/hadoop/.ssh
chmod 600 /home/hadoop/.ssh/authorized_keys
chmod 600 /home/hadoop/.ssh/id_rsa
chmod 644 /home/hadoop/.ssh/id_rsa.pub
chown -R hadoop:hadoop /home/hadoop/.ssh

# Copy update config files to etc/hadoop

cd /efs/hadoop-cluster-on-aws && git pull # Update config files

for file in hadoop-env.sh core-site.xml hdfs-site.xml mapred-site.xml yarn-site.xml slaves yarn-env.sh
do
cp /efs/hadoop-cluster-on-aws/configs/$file /kkb/install/$cdh/etc/hadoop/$file
done
chmod 755 /kkb/install/$cdh/etc/hadoop/*.sh

EOF
}

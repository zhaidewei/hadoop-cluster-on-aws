# hadoop-cluster-on-aws

Setup my own Hadoop cluster on AWS Ec2

## Terraform

Terraform v0.12.19

```bash
aws-vault create dewei

```

Input IAM user secret.
Config aws config at ~/.aws/config

```bash
[profile dewei]
user_arn=arn:aws:iam::733829533973:user/dewei_IAM
region = eu-west-1
output = json
session-ttl=1h
assume-role-ttl=1h
```

Life cycle.

```bash
aws-vault exec dewei terraform init
aws-vault exec dewei terraform plan
aws-vault exec dewei terraform apply
aws-vault exec dewei terraform destroy
```

###

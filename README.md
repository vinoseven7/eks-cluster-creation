## Examples

```hcl
module "eks-creation" {
  source = "C:/Rajesh-material/eks-cluster-creation"
  subnet_id_1 = "subnet-0141198e30284b652"
  subnet_id_2 = "subnet-0e634871598ca60ab"
  bastion_instance_type = "t2.micro"
  ssh_key_name = "eks-learning"
  vpc_id = "vpc-00b49215616b433a0"
  cidr_block = "10.0.0.0/16"
  bastion_name = "EKS-Bastion"
}
```

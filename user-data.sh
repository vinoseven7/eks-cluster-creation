#!/bin/bash

setenforce 0 ;
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux ;modprobe br_netfilter ;
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables ;yum install -y yum-utils device-mapper-persistent-data lvm2 ;
yum install -y docker ; systemctl enable docker ;systemctl start docker ;

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet kubeadm kubectl ;
systemctl enable kubelet ;

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.17/2023-08-16/bin/linux/amd64/kubectl ;
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.17/2023-08-16/bin/linux/amd64/kubectl.sha256 ;
sha256sum -c kubectl.sha256 ;
openssl sha1 -sha256 kubectl ;
chmod +x ./kubectl ;
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH ;
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc ;
kubectl version --short --client;
#aws eks update-kubeconfig --region us-east-1 --name Learning-cluster
yum install git -y;
yum install make -y ;
yum install go -y ;
git clone https://github.com/helm/helm.git
cd helm
make;
echo 'export PATH=/root/helm/bin/:$PATH' >> ~/.bashrc;
helm version;

# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo mv /tmp/eksctl /usr/local/bin
echo 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc;

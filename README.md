Setup Guide

- Create Terraform backend

  - Create S3 bucket for backend
  - Create DynamoDB

- Terraform init

- create network

- create keypairs

  - chmod 400 on privatekey

- create ec2 instances

run all_nodes script and master script on master

add nodes - "kubeadm token create --print-join-command" on master will print join command for nodes

label nodes

kubectl label node "node_name" node-role.kubernetes.io/worker=worker

deploy metric manifest...note that tls insecure is set to true.

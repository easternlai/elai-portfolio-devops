# This folder was used for testing of deploying bare metal kubernetes on AWS. Retiring this effort as there was too many inherent issues with running MetalLb on AWS but retaining a copy for future reference.

# Below are the notes for the effort

Setup Guide

- Create Terraform backend

  - Create S3 bucket for backend
  - Create DynamoDB

- Terraform init

- create network

- create keypairs

  - chmod 600 on privatekey

- create ec2 instances

run all_nodes script and master script on master

add nodes - "kubeadm token create --print-join-command" on master will print join command for nodes

label nodes
kubectl label node "node_name" node-role.kubernetes.io/worker=worker

deploy metric manifest...note that tls insecure is set to true.

# nginx controller

# install helm

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# add repo

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm search repo ingress-nginx --versions

CHART_VERSION="4.9.0"
APP_VERSION="1.9.4"

helm template ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--version ${CHART_VERSION} \
--namespace ingress-nginx \

> ./nginx-ingress.${APP_VERSION}.yaml

kubectl create namespace ingress-nginx
kubectl apply -f ./nginx-ingress.1.9.4.yaml

kubectl -n ingress-nginx get pods

kubectl -n ingress-nginx get svc

kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 443

## metallb

kubectl edit configmap -n kube-system kube-proxy - make strict arp under ipvs = true

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

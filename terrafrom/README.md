# Infrastructure

using workspace: dev

add eks context to kubectl config
aws eks --region eu-central-1 update-kubeconfig --name optar-dev-eks-gRI4vwi5

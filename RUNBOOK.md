# Runbook

## getting started

To also pull the submodules, make sure to clone this repo like this:  
`git clone --recurse-submodules https://github.com/Askill/Web-Crawler-on-EKS`

## CI

In this Github repo, there are multiple workflows:

- to deploy all infrastructure
  - runs on push to main or during a PR
- to destroy all infrastructure
  - manual action
- to deploy a new latest version of the aplication
  - runs on push to main in this repo

### Image build

The app image can be built with:  
`docker build -t 705632797485.dkr.ecr.eu-central-1.amazonaws.com/optar:latest-dev ./optar`  
`docker push  705632797485.dkr.ecr.eu-central-1.amazonaws.com/optar:latest-dev`

## Deployment

The crawler is deployed as a K8s Job, defined in ./optar/deployment.yaml
Which can be rolled out to the cluster with:  
`kubectl apply -f .\deployment.yaml`

Prerequisite: the correct kubectl config has been set with:   
`aws eks --region eu-central-1 update-kubeconfig --name optar-dev-eks`

## Crawler config

For this PoC, no changes have been made to how the crawler gets its config, meaning the sites and keywords are set during build time as lines in `./optar/keywords.txt` and `./optar/sites.txt`.

## AWS Infrastructure

Components of note:

- EKS cluster
  - using the standard Terraform EKS module, which utilizes ECS under the hood for auto managed nodes
  - also has a service account which can read from the S3 bucket, the application needs, the account is specified in `./optar.deployment.yaml`
- ECR
  - created one registry (optar)
  - all users and roles in the account have pull and push access, fine for low security applications
- S3 Bucket
  - lifecycle rule to delete objects older that 3 days, assuming this crawler is run at least once per day, this leaves some room for error, while also ensuring low overhead
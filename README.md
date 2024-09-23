# Web-Crawler-on-EKS [![Terraform](https://github.com/Askill/Web-Crawler-on-EKS/actions/workflows/terraform.yml/badge.svg)](https://github.com/Askill/Web-Crawler-on-EKS/actions/workflows/terraform.yml) [![Deploy Optar to k8s](https://github.com/Askill/Web-Crawler-on-EKS/actions/workflows/k8s_deploy.yml/badge.svg)](https://github.com/Askill/Web-Crawler-on-EKS/actions/workflows/k8s_deploy.yml)

## Hiring Tasks

Here’s the translation:

- Use `terraform` to implement this task. If possible, feel free to use `terragrunt`.
- Use a CI/CD tool of your choice to execute the Terraform code.
- Use a git repository (or repositories) to manage your code.
- Build a Docker container (or use an existing one) that runs a simple one-time crawler job against a website of your choice.
  - *Running a one-time crawler on EKS doesn’t seem sensible to me. Normally, I would discuss with the client why EKS was chosen and whether an alternative might be more appropriate.*
  - *A more reasonable approach seems to be:*
    - *either: a Kubernetes cronjob*
    - *or: an ECS Fargate scheduled task / Lambda, depending on runtime and other requirements*
- The crawler job should save the data to an S3 bucket.
  - *For the chosen crawler, the result would most likely be sent via SNS, but the S3 bucket is used as a cache in this case, so both read and write operations are implemented on the bucket.*
- Provision this container in AWS on an EKS cluster where the job will be executed.
- Ensure the code is tested.
  - *The tests demonstrate the basics, but extensive implementation or high test coverage has been deliberately avoided.*
- Prepare and present a deployment concept.
- Prepare your solution as if you were presenting it to a client.

## Solution

See ./RUNBOOK.md for technical details on the implementation.

All code, comments and documentation are written in english, as I am a big fan of lived inclusivity. Unless specifically requests otherwise by the client I prefere english as my working language, even if the current team at the client is fully german speaking, as they might decide in the future to hire international developers.

### Crawler

I reused a crawler I had made earlier: `https://github.com/Askill/optar`  
This crawler traverses all links on a given website, caches this tree, compares the new tree to previously cached ones and searches all *new* sites for specific keywords.
This crawler is specifically designed for news sites and blogs and not for content changes on normally static sites like a companies home page.

TODO:

- tests
  - unit tests: ✔️ tested manually, not robust enough to be a library, code coverage of 80% or higher would be unreasonable time invest
  - int tests:
    - local mock site ❌ not doing
    - pytest code ✔️
- docker-compose ✔️
- make work with S3 ✔️

### CI/CD

Use github actions
This section builds on top of this repository:  
<https://github.com/trackit/terraform-boilerplate>, from a small AWS partnered consultancy in LA
The last commit was about 3 years ago, which is why I forked it and would, in a production environment, continue working on my fork: <https://github.com/Askill/terraform-boilerplate>
As some of the terraform code is using deprecated variables, only the ci/cd code is used.

TODO:

- setup github actions ✔️
- build image ✔️
- run tests ✔️
- run terraform deploy ✔️

### AWS

TODO:

- setup terraform ✔️
  - <https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks>
- create Kubernetes deployment ✔️
- create s3 ✔️
- allow s3 access from terraform ✔️
- adjust container to pull sites.txt and keywords.txt contents from config map (or s3, if no time)❌
  - not doing

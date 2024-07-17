# Web-Crawler-on-EKS [![Terraform](https://github.com/Askill/Web-Crawler-on-EKS/actions/workflows/terraform.yml/badge.svg)](https://github.com/Askill/Web-Crawler-on-EKS/actions/workflows/terraform.yml) [![Deploy Optar to k8s](https://github.com/Askill/Web-Crawler-on-EKS/actions/workflows/k8s_deploy.yml/badge.svg)](https://github.com/Askill/Web-Crawler-on-EKS/actions/workflows/k8s_deploy.yml)

## Tasks

- Nutze `terraform` um diese Aufgabe umzusetzen. Wenn möglich gerne auch `terragrunt`.
- Mittels eines CI/CD Tools deiner Wahl soll der Terraform Code ausgeführt werden
- Nutze ein git repository(s), um deinen Code zu verwalten.
- Bau einen Docker Container (oder nutze einen vorhanden) der einen einfachen/einmaligen Crawler Job ausführt gegen eine Webseite deiner Wahl.
  - *einmalger crawler run auf EKS erscheint mir nicht sinnvoll, hier würde ich üblicher Weise mit dem Kunden sprechen, warum EKS gewählt wurde und ob eine Alternative besser geeignet wäre.*
  - *sinnvoller erscheint mir:*
    - *entweder: kubernetes cronjob*
    - *oder: ECS fargate scheduled task / lambda, abhängig von der Laufzeit und weiteren Anforderungen*
- Der Crawler Job soll die Daten auf einem S3 Bucket abspeichern.
  - *bei dem gewählten crawler würde das Ergebnis am ehesten per SNS abgesetzt, der S3 bucket wird in diesem Fall aber als Cache genutzt, somint sind read und write auf dem Bucket implementiert*
- Provisioniere diesen Container in der AWS auf einem EKS Cluster, wo der Job ausgeführt werden soll.
- Stell sicher das der Code getestet wird
  - *Tests demonstrieren die basics, auf extensive Implementierung oder hohe Testabdeckung wurde aber bewusst verzichtet*
- Bereite ein Deployment-Konzept auf und stelle es dar.
- Bereite deine Lösung vor, als würdest du sie einem Kunden vorstellen.

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

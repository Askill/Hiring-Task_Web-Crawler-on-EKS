# Web-Crawler-on-EKS

### Tasks:

- Nutze `terraform` um diese Aufgabe umzusetzen. Wenn möglich gerne auch `terragrunt`. 
- Mittels eines CI/CD Tools deiner Wahl soll der Terraform Code ausgeführt werden. 
- Nutze ein git repository(s), um deinen Code zu verwalten. 
- Bau einen Docker Container (oder nutze einen vorhanden) der einen einfachen/einmaligen Crawler Job ausführt gegen eine Webseite deiner Wahl. 
- Der Crawler Job soll die Daten auf einem S3 Bucket abspeichern. 
- Provisioniere diesen Container in der AWS auf einem EKS Cluster, wo der Job ausgeführt werden soll. 
- Stell sicher das der Code getestet wird
- Bereite ein Deployment-Konzept auf und stelle es dar.
- Bereite deine Lösung vor, als würdest du sie einem Kunden vorstellen. 

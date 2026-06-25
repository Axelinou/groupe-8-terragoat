# Architecture du pipeline DevSecOps

## Vue d'ensemble

Le pipeline est orchestre par GitHub Actions et se declenche
automatiquement a chaque push ou Pull Request sur la branche master.
Il est compose de 3 jobs independants qui s'executent en parallele.

---

## Detail des jobs

### Job 1 - Analyse statique IaC (Checkov)

Outil : Checkov 3.3.2 by Prisma Cloud
Role : Analyser le code Terraform et detecter les mauvaises
configurations de securite avant tout deploiement.

Resultats obtenus :
- Passed checks : 203
- Failed checks : 467
- Checks couverts : chiffrement, acces reseau, logging, IAM

Rapport genere : checkov-report.json
Archive dans : GitHub Actions Artifacts

### Job 2 - Detection de secrets (Gitleaks)

Outil : Gitleaks Action v2
Role : Scanner tout le depot Git pour detecter des secrets
exposes comme des cles API, mots de passe ou tokens.

Secrets detectes dans TerraGoat :
- Cles AWS hardcodees dans terraform/aws/providers.tf
- Cles AWS hardcodees dans terraform/aws/ec2.tf
- Chaines Base64 a haute entropie dans terraform/aws/lambda.tf

### Job 3 - Validation Terraform

Outil : Terraform CLI 1.5.7 by HashiCorp
Role : Verifier que le code Terraform est syntaxiquement valide
avant tout deploiement.

Commandes executees :
- terraform init -backend=false
- terraform validate

---

## Outils utilises

| Outil | Version | Role |
|---|---|---|
| Checkov | 3.3.2 | Analyse statique IaC |
| Gitleaks | v2 | Detection de secrets |
| Terraform | 1.5.7 | Validation IaC |
| GitHub Actions | - | Orchestration CI/CD |

---

## Declencheurs du pipeline

- Push sur la branche master
- Pull Request vers la branche master

---

## Archivage des rapports

Les rapports sont archives automatiquement dans GitHub Actions
sous forme d'Artifacts telechargeables depuis l'onglet Actions
du depot GitHub.

Rapport disponible : checkov-report.json

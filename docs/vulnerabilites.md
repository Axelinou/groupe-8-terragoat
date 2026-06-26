# Vulnerabilites identifiees

## Resultats de l'analyse Checkov

Outil : Checkov 3.3.2
Date d'analyse : 2025
Perimetre : dossier terraform/

Passed checks : 203
Failed checks : 467
Skipped checks : 0

---

## Vulnerabilites critiques corrigees

### 1. CKV_AWS_41 - Cles AWS hardcodees dans providers.tf

Fichier : terraform/aws/providers.tf
Ressource : aws.plain_text_access_keys_provider
Criticite : CRITIQUE

Description : Des cles d'acces AWS etaient ecrites en clair directement
dans le code source. Toute personne ayant acces au depot pouvait
recuperer ces credentials et compromettre le compte AWS.

Cle exposee : AKIAIOSFODNN7EXAMPLE
Secret expose : wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

Correction : Suppression des cles hardcodees. Les credentials
sont desormais geres via des variables d'environnement ou
le fichier ~/.aws/credentials.

---

### 2. CKV_AWS_19, CKV_AWS_21, CKV2_AWS_6 - Bucket S3 non securise

Fichier : terraform/aws/s3.tf
Ressource : aws_s3_bucket.data
Criticite : HAUTE

Description : Le bucket S3 "data" presentait plusieurs problemes :
- Aucun chiffrement des donnees au repos
- Acces public non bloque
- Pas de versioning active
- Pas de logs d'acces

Correction : Ajout des ressources suivantes :
- aws_s3_bucket_server_side_encryption_configuration (chiffrement KMS)
- aws_s3_bucket_versioning (versioning active)
- aws_s3_bucket_public_access_block (blocage acces public)
- aws_s3_bucket_logging (logs actives)

---

### 3. CKV_AWS_24, CKV_AWS_260 - Security group ouvert a internet

Fichier : terraform/aws/ec2.tf
Ressource : aws_security_group.web-node
Criticite : HAUTE

Description : Le security group autorisait les connexions SSH (port 22)
et HTTP (port 80) depuis n'importe quelle adresse IP (0.0.0.0/0).
Cela expose l'instance EC2 a des attaques depuis internet.

Correction : Restriction du security group existant (web-node)
pour limiter l'acces SSH et HTTP au reseau interne (10.0.0.0/8).
Ajout d'un security group securise supplementaire (web-node-secure).

---

### 4. CKV_AWS_46 - Credentials AWS dans user_data EC2

Fichier : terraform/aws/ec2.tf
Ressource : aws_instance.web_host
Criticite : CRITIQUE

Description : Des credentials AWS etaient injectes en clair dans
le script de demarrage (user_data) de l'instance EC2.

Correction : Suppression des credentials du user_data et ajout
d'un IAM Instance Profile pour fournir les permissions via IAM Role.

---

## Vulnerabilites identifiees non corrigees

Ces vulnerabilites ont ete identifiees mais non corrigees
car elles necessitent une infrastructure AWS reelle pour etre deployees.

- CKV_AWS_16 : Chiffrement RDS non active
- CKV_AWS_17 : Instance RDS accessible publiquement
- CKV_AWS_37 : Logs EKS non actives
- CKV_AWS_58 : Chiffrement secrets EKS non active
- CKV_AWS_84 : Logs Elasticsearch non actives
- CKV_AWS_115 : Lambda sans limite de concurrence
- CKV_AWS_157 : RDS sans Multi-AZ

Pour le rapport complet : voir les artifacts GitHub Actions (checkov-report.json)

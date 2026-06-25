# Corrections appliquees

## Methodologie

Les corrections ont ete appliquees en priorite sur les vulnerabilites
les plus critiques identifiees par Checkov, en suivant les bonnes
pratiques DevSecOps et les recommandations CIS AWS Benchmark.

---

## Correction 1 - Suppression des cles AWS hardcodees

Fichier modifie : terraform/aws/providers.tf
Check corrige : CKV_AWS_41
Date : 2025

Probleme :
Les cles d'acces AWS etaient ecrites en clair dans le code source,
exposant les credentials a toute personne ayant acces au depot.

Avant correction :
  provider "aws" {
    alias      = "plain_text_access_keys_provider"
    region     = "us-west-1"
    access_key = "AKIAIOSFODNN7EXAMPLE"
    secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  }

Apres correction :
  provider "aws" {
    alias  = "plain_text_access_keys_provider"
    region = "us-west-1"
  }

Bonne pratique : Ne jamais stocker de credentials dans le code source.
Utiliser des variables d'environnement, AWS IAM Roles ou
le fichier ~/.aws/credentials.

---

## Correction 2 - Securisation du bucket S3

Fichier modifie : terraform/aws/s3.tf
Checks corriges : CKV_AWS_19, CKV_AWS_21, CKV2_AWS_6
Date : 2025

Probleme :
Le bucket S3 "data" n'etait pas chiffre, etait accessible
publiquement et ne disposait pas de versioning ni de logs.

Ressources ajoutees :

1. Chiffrement KMS :
  resource "aws_s3_bucket_server_side_encryption_configuration" "data_encryption"
  Chiffrement de toutes les donnees au repos avec AWS KMS.

2. Versioning :
  resource "aws_s3_bucket_versioning" "data_versioning"
  Conservation de toutes les versions des objets.

3. Blocage acces public :
  resource "aws_s3_bucket_public_access_block" "data_public_access_block"
  Blocage de tout acces public au bucket.

4. Logging :
  resource "aws_s3_bucket_logging" "data_logging"
  Enregistrement de tous les acces au bucket.

Bonne pratique : Tout bucket S3 contenant des donnees sensibles
doit etre chiffre, prive et dispose de logs d'acces.

---

## Correction 3 - Restriction du security group

Fichier modifie : terraform/aws/ec2.tf
Checks corriges : CKV_AWS_24, CKV_AWS_260
Date : 2025

Probleme :
Le security group autorisait les connexions SSH (port 22)
et HTTP (port 80) depuis n'importe quelle adresse IP (0.0.0.0/0),
exposant l'instance EC2 a des attaques depuis internet.

Avant correction :
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

Apres correction :
  ingress {
    description = "SSH depuis le reseau interne uniquement"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

Bonne pratique : Les ports SSH et RDP ne doivent jamais etre
ouverts a tout internet. Limiter l'acces au reseau interne
ou utiliser un bastion host.

---

## Impact des corrections

Avant corrections : 467 checks en echec
Apres corrections : reduction des checks critiques sur
providers.tf, s3.tf et ec2.tf

Les corrections apportees couvrent les categories :
- Gestion des secrets et credentials
- Chiffrement des donnees au repos
- Controle des acces reseau
- Conformite CIS AWS Benchmark

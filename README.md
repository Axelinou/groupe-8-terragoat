# Projet DevSecOps – Groupe 8 – TerraGoat

* *Étudiants :* Clement VAUCLARE, Maxime GUILBAUD, Axel BARBESIER
* *Formation :* Mastère Infrastructure 1 – Ynov Aix-en-Provence (2026)
* *Module :* DevSecOps
* *Intervenant :* Damien Montmoulinex


# 1. Présentation du projet

Dans le cadre du module DevSecOps du Mastère Infrastructure d’Ynov Aix-en-Provence, ce projet a pour objectif de concevoir et déployer une chaîne CI/CD intégrant la sécurité à chaque étape du cycle de développement.

Pour cette mise en pratique, nous avons utilisé **TerraGoat**, un projet open source développé par Bridgecrew. Celui-ci contient volontairement de nombreuses vulnérabilités au sein de son infrastructure Terraform afin de reproduire des erreurs de configuration fréquemment rencontrées dans les environnements cloud réels.

Les objectifs fixés étaient les suivants :

* Mettre en place une chaîne CI/CD complète avec GitHub Actions ;
* Automatiser les analyses de sécurité de l’Infrastructure as Code (IaC) ;
* Identifier les mauvaises configurations de sécurité ;
* Corriger les vulnérabilités les plus critiques ;
* Générer et conserver les rapports d’analyse ;
* Documenter les risques détectés, les corrections réalisées et les bonnes pratiques appliquées.

---

# 2. Environnement de travail

## Système d’exploitation

* Windows 11
* WSL2 (Ubuntu)

## Outils installés localement

* Python 3 / pip3
* Checkov 3.3.2
* Gitleaks 8.18.4
* Terraform 1.5.7
* Git 2.x

## Dépôt et orchestration

* Dépôt GitHub : [https://github.com/Axelinou/groupe-8-terragoat](https://github.com/Axelinou/groupe-8-terragoat)
* Orchestrateur CI/CD : GitHub Actions

---

# 3. Outils utilisés

| Outil          | Version | Rôle                                   | Catégorie              |
| -------------- | ------- | -------------------------------------- | ---------------------- |
| Checkov        | 3.3.2   | Analyse statique du code Terraform     | SAST                   |
| Gitleaks       | 8.18.4  | Détection de secrets dans le dépôt     | Secret Scanning        |
| Terraform CLI  | 1.5.7   | Validation syntaxique de l’IaC         | Infrastructure as Code |
| GitHub Actions | -       | Exécution et orchestration du pipeline | CI/CD                  |

---

# 4. Architecture du pipeline CI/CD

Le pipeline est défini dans le fichier :

`.github/workflows/devsecops.yml`

Il est exécuté automatiquement :

* lors d’un **push** sur la branche `master` ;
* lors d’une **Pull Request** vers la branche `master`.

Les différents traitements sont répartis en trois jobs indépendants exécutés en parallèle.

## Job 1 – Analyse statique IaC (Checkov)

Étapes réalisées :

1. Récupération du code source ;
2. Installation de Checkov ;
3. Analyse du répertoire `terraform/` ;
4. Génération d’un rapport JSON ;
5. Archivage du rapport dans les Artifacts GitHub Actions.

## Job 2 – Détection de secrets (Gitleaks)

Étapes réalisées :

1. Récupération du code source ;
2. Analyse complète du dépôt ;
3. Recherche de credentials et secrets exposés ;
4. Affichage des résultats dans les logs CI.

## Job 3 – Validation Terraform

Étapes réalisées :

1. Récupération du code source ;
2. Installation de Terraform 1.5.7 ;
3. Exécution de `terraform init` ;
4. Exécution de `terraform validate`.

---

# 5. Résultats des analyses de sécurité

## Analyse Checkov

**Outil :** Checkov 3.3.2 (Prisma Cloud)

**Périmètre analysé :**

* AWS
* Azure
* GCP
* AliCloud
* Oracle Cloud

### Résultats

| Indicateur         | Nombre |
| ------------------ | ------ |
| Contrôles validés  | 203    |
| Contrôles en échec | 467    |
| Contrôles ignorés  | 0      |

### Principales catégories de vulnérabilités détectées

* Absence de chiffrement des données au repos ;
* Ressources accessibles publiquement ;
* Secrets et credentials codés en dur ;
* Absence de mécanismes de journalisation et de supervision ;
* Security Groups trop permissifs ;
* Authentification IAM non activée ;
* Absence de versioning sur les buckets ;
* Mauvaise configuration des clusters Kubernetes ;
* Bases de données exposées publiquement.

---

# 6. Secrets détectés par Gitleaks

L’analyse du dépôt a permis d’identifier plusieurs secrets exposés.

### terraform/aws/providers.tf

**Type :** AWS Access Key hardcodée

Valeur exposée :

```text
AKIAIOSFODNN7EXAMPLE
```

**Autre détection :**

* Chaîne Base64 à forte entropie ;
* Secret AWS présent dans la configuration du provider.

### terraform/aws/lambda.tf

Détections :

* AWS Access Key hardcodée ;
* Secret Base64 présent dans les variables d’environnement Lambda.

### terraform/aws/ec2.tf

**Type :** AWS Access Key hardcodée dans le script `user_data`

Valeur exposée :

```text
AKIAIOSFODNN7EXAMAAA
```

Description :

* Credentials AWS injectés en clair dans le script de démarrage EC2.

### terraform/azure/sql.tf

Détection :

* Secret Base64 à forte entropie présent dans la configuration SQL Azure.

---

# 7. Vulnérabilités critiques corrigées

## 7.1 Clés AWS stockées en clair

### Informations

* Checkov : CKV_AWS_41
* Fichier : `terraform/aws/providers.tf`
* Ressource : `aws.plain_text_access_keys_provider`
* Criticité : Critique

### Description

Les identifiants AWS étaient directement intégrés au code Terraform, permettant à toute personne ayant accès au dépôt de compromettre le compte AWS associé.

### Correction apportée

Suppression complète des clés d’accès du code source.

Les credentials sont désormais récupérés via :

* Variables d’environnement ;
* Fichier `~/.aws/credentials`.

### Bonne pratique

Ne jamais stocker de credentials dans le code source. Privilégier :

* AWS IAM Roles ;
* AWS Secrets Manager ;
* Variables d’environnement sécurisées.

---

## 7.2 Bucket S3 insuffisamment sécurisé

### Informations

* Checks : CKV_AWS_19, CKV_AWS_21, CKV2_AWS_6
* Fichier : `terraform/aws/s3.tf`
* Ressource : `aws_s3_bucket.data`
* Criticité : Haute

### Problèmes identifiés

* Données non chiffrées ;
* Versioning désactivé ;
* Accès public autorisé ;
* Absence de journaux d’accès.

### Correctifs appliqués

1. Mise en place du chiffrement KMS ;
2. Activation du versioning ;
3. Blocage complet des accès publics ;
4. Activation de la journalisation des accès.

### Bonne pratique

Tout bucket contenant des données sensibles doit :

* être privé ;
* être chiffré ;
* disposer du versioning ;
* conserver les logs d’accès.

---

## 7.3 Security Group exposé à Internet

### Informations

* Checks : CKV_AWS_24, CKV_AWS_260
* Fichier : `terraform/aws/ec2.tf`
* Ressource : `aws_security_group.web-node`
* Criticité : Haute

### Description

Le Security Group autorisait les connexions SSH (22) et HTTP (80) depuis l’ensemble d’Internet via la plage :

```text
0.0.0.0/0
```

Cette configuration exposait l’instance à :

* des attaques par force brute ;
* des scans de ports ;
* des tentatives d’intrusion.

### Correction appliquée

Création d’un Security Group restreignant les accès administratifs au réseau interne :

```text
10.0.0.0/8
```

### Bonne pratique

Les ports d’administration (SSH, RDP) ne doivent jamais être ouverts publiquement.

L’utilisation :

* d’un bastion ;
* ou d’un VPN

doit être privilégiée.

---

# 8. Vulnérabilités identifiées mais non corrigées

Certaines vulnérabilités n’ont pas été corrigées car leur traitement nécessite un environnement AWS réel déployé.

| Check       | Fichier   | Description                          | Criticité |
| ----------- | --------- | ------------------------------------ | --------- |
| CKV_AWS_16  | db-app.tf | Chiffrement RDS absent               | Haute     |
| CKV_AWS_17  | db-app.tf | Instance RDS publique                | Haute     |
| CKV_AWS_37  | eks.tf    | Logs EKS désactivés                  | Haute     |
| CKV_AWS_58  | eks.tf    | Chiffrement des secrets EKS absent   | Haute     |
| CKV_AWS_161 | db-app.tf | IAM Authentication RDS désactivée    | Haute     |
| CKV_AWS_84  | es.tf     | Logs Elasticsearch désactivés        | Moyenne   |
| CKV_AWS_115 | lambda.tf | Limite de concurrence Lambda absente | Moyenne   |
| CKV_AWS_157 | rds.tf    | Multi-AZ désactivé                   | Moyenne   |
| CKV_AWS_92  | elb.tf    | Logs ELB désactivés                  | Moyenne   |
| CKV_AWS_51  | ecr.tf    | Tags ECR non immuables               | Moyenne   |

---

# 9. Bonnes pratiques DevSecOps appliquées

## Shift Left Security

La sécurité est intégrée dès le début du cycle de développement grâce aux analyses automatiques déclenchées à chaque modification du code.

## Gestion des secrets

* Aucun credential ne doit être stocké dans le dépôt.
* Utilisation de variables d’environnement et de gestionnaires de secrets.
* Détection automatique via Gitleaks.

## Principe du moindre privilège

Les ressources ne disposent que des permissions strictement nécessaires à leur fonctionnement.

## Chiffrement des données

Toutes les données sensibles doivent être protégées :

* au repos ;
* en transit.

## Traçabilité et audit

* Journalisation activée ;
* Archivage des rapports ;
* Historique Git conservé.

## Automatisation de la sécurité

Les contrôles de sécurité sont exécutés automatiquement :

* Checkov ;
* Gitleaks ;
* Terraform Validate.

## Infrastructure as Code

L’ensemble de l’infrastructure est :

* versionné ;
* auditable ;
* reproductible.

---

# 10. Rapports de sécurité

Les rapports sont générés automatiquement lors de chaque exécution du pipeline et stockés dans les Artifacts GitHub Actions.

### Consultation

1. Ouvrir l’onglet **Actions** du dépôt GitHub ;
2. Sélectionner une exécution du pipeline ;
3. Télécharger l’Artifact :

```text
checkov-report.json
```

---

# 11. Structure du dépôt

| Élément                           | Description                        |
| --------------------------------- | ---------------------------------- |
| `.github/workflows/devsecops.yml` | Pipeline CI/CD                     |
| `docs/architecture.md`            | Architecture détaillée du pipeline |
| `docs/vulnerabilites.md`          | Liste des vulnérabilités détectées |
| `docs/corrections.md`             | Corrections appliquées             |
| `docs/bonnes-pratiques.md`        | Bonnes pratiques DevSecOps         |
| `reports/`                        | Rapports générés automatiquement   |
| `terraform/`                      | Code TerraGoat d’origine           |

---

# 12. Documentation complémentaire

* `docs/architecture.md` : architecture détaillée du pipeline ;
* `docs/vulnerabilites.md` : inventaire des vulnérabilités ;
* `docs/corrections.md` : correctifs implémentés ;
* `docs/bonnes-pratiques.md` : pratiques DevSecOps mises en œuvre.

---

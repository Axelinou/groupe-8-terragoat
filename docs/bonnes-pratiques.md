# Bonnes pratiques DevSecOps appliquees

## 1. Shift Left Security

La securite est integree des le debut du cycle de developpement
et non ajoutee en fin de processus. Chaque push sur le depot
declenche automatiquement les analyses de securite via GitHub Actions.

---

## 2. Gestion des secrets

Ne jamais stocker de credentials dans le code source.
Regles appliquees :
- Suppression des cles AWS hardcodees dans providers.tf
- Utilisation de variables d'environnement pour les credentials
- Detection automatique des secrets via Gitleaks a chaque push

Outils utilises : Gitleaks

---

## 3. Principe du moindre privilege

Chaque ressource ne doit avoir acces qu'a ce dont elle a besoin.
Regles appliquees :
- Security groups limites au reseau interne (10.0.0.0/8)
- Buckets S3 avec blocage d'acces public
- Suppression des providers avec credentials hardcodes

---

## 4. Chiffrement des donnees

Toutes les donnees sensibles doivent etre chiffrees au repos
et en transit.
Regles appliquees :
- Chiffrement KMS sur les buckets S3
- Backend Terraform avec chiffrement active
- Chiffrement des volumes EBS recommande

---

## 5. TraÃ§abilite et audit

Toutes les actions doivent etre tracees et auditables.
Regles appliquees :
- Logging active sur les buckets S3
- Versioning active pour conserver l'historique des objets
- Rapports de securite archives dans GitHub Actions Artifacts
- Historique Git de toutes les modifications

---

## 6. Automatisation de la securite

La securite ne doit pas dependre d'actions manuelles.
Pipeline mis en place :
- Checkov : analyse statique IaC a chaque push
- Gitleaks : detection de secrets a chaque push
- Terraform validate : validation syntaxique a chaque push
- Archivage automatique des rapports en artifacts

---

## 7. Infrastructure as Code

Toute infrastructure doit etre definie en code,
versionnee et auditee.
Avantages :
- Reproductibilite des environnements
- Historique des changements via Git
- Revue de code possible sur l'infrastructure
- Detection des derives de configuration

---

## 8. References

- CIS AWS Benchmark : https://www.cisecurity.org/benchmark/amazon_web_services
- OWASP Top 10 IaC Security : https://owasp.org/www-project-top-10-ci-cd-security-risks
- Checkov documentation : https://www.checkov.io
- Gitleaks documentation : https://github.com/gitleaks/gitleaks
- AWS Security Best Practices : https://aws.amazon.com/security/security-resources

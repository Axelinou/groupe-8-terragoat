provider "aws" {
  profile = var.profile
  region  = var.region
}

# CORRECTION CKV_AWS_41 : Suppression des clés AWS hardcodées
# Les credentials sont désormais gérés via des variables d'environnement
# ou le fichier ~/.aws/credentials
# Ancienne configuration vulnérable :
# access_key = "AKIAIOSFODNN7EXAMPLE"
# secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
provider "aws" {
  alias  = "plain_text_access_keys_provider"
  region = "us-west-1"
}

terraform {
  backend "s3" {
    encrypt = true
  }
}

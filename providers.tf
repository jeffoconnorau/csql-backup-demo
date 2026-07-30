terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  alias   = "backup"
  project = var.backup_project_id
}

provider "google-beta" {
  alias   = "backup"
  project = var.backup_project_id
}

provider "google" {
  alias   = "lab"
  project = var.lab_project_id
}

provider "google-beta" {
  alias   = "lab"
  project = var.lab_project_id
}

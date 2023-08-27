terraform {
  required_version = ">=1.5.5"
  backend "gcs" {
    bucket = "arikkfir-devops"
    prefix = "terraform"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 4.78.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "= 4.78.0"
    }
  }
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project to deploy resources."
}

variable "gcp_region" {
  type        = string
  description = "Region to place compute resources."
}

output "gcp_region" {
  # redirect variable to an output, so it can be used in a GHA workflow-dispatch job (it can't use env vars)
  value = var.gcp_region
}

locals {
  gcp_zone_a = "${var.gcp_region}-a"
  gcp_zone_b = "${var.gcp_region}-b"
  gcp_zone_c = "${var.gcp_region}-c"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
}

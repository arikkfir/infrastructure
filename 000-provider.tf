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

variable "gcp-project-id" {
  type        = string
  description = "GCP project to deploy resources."
}

variable "gcp-region" {
  type        = string
  description = "Region to place compute resources."
}

locals {
  gcp_zone_a = "${var.gcp-region}-a"
  gcp_zone_b = "${var.gcp-region}-b"
  gcp_zone_c = "${var.gcp-region}-c"
}

provider "google" {
  project = var.gcp-project-id
  region  = var.gcp-region
  zone    = "${var.gcp-region}-a"
}

provider "google-beta" {
  project = var.gcp-project-id
  region  = var.gcp-region
  zone    = "${var.gcp-region}-a"
}

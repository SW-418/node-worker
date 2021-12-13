terraform {

  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = var.terraform_org

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = var.feature_name
    }
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("node-worker-gcp-config.json") // Extract and store
  project = "${var.feature_name}-${var.gcp_project_id}"
  region  = var.gcp_region
  zone    = var.gcp_zone
}

resource "google_storage_bucket" "node-worker-bucket" {
  name = var.feature_name
  location = var.gcp_region

  labels = {
    feature = var.feature_name
  }
}

data "archive_file" "code" {
  type        = "zip"
  output_path = "${path.module}/dist.zip"
  source {
    content  = "${file("../dist/function.js")}"
    filename = "function.js"
  }
}
resource "google_storage_bucket_object" "node-worker-code" {
  name   = "dist.zip"
  bucket = google_storage_bucket.node-worker-bucket.name
  source = "${path.module}/dist.zip"
}

resource "google_pubsub_topic" "node-worker-topic" {
  name = "${var.feature_name}-topic"

  labels = {
    feature = var.feature_name
  }
}

terraform {
  required_version = "= 0.12.28"
  backend "gcs" {
    bucket = "terraform-rugamaga"
  }
}

provider "google" {
  project = local.workspace.project
  region  = "asia-northeast1"
}

data "google_container_engine_versions" "target" {
  location       = "asia-northeast1"
  version_prefix = "1.16"
}

resource "google_container_cluster" "primary" {
  name = "gke-rugamaga"

  min_master_version = data.google_container_engine_versions.target.latest_master_version

  location = "asia-northeast1-a"

  initial_node_count       = 1
  remove_default_node_pool = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_container_node_pool" "nodes" {
  name     = "nodes-rugamaga"
  cluster  = google_container_cluster.primary.name
  version  = data.google_container_engine_versions.target.latest_node_version
  location = "asia-northeast1-a"

  initial_node_count = 2
  autoscaling {
    min_node_count = 2
    max_node_count = 4
  }

  management {
    auto_repair = true
  }

  node_config {
    preemptible  = true
    machine_type = local.workspace.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

module "domain" {
  source = "./modules/domain"

  name = "rugamaga"
  root = local.workspace.domain_name

  domains = [
    {
      name   = "root-rugamaga"
      domain = local.workspace.domain_name
    },
    {
      name   = "image-rugamaga"
      domain = "image.${local.workspace.domain_name}"
    },
  ]
}

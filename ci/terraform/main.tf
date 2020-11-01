terraform {
  required_version = ">= 0.12"
}

provider "google" {
  version     = "3.40.0"
  region      = var.gcp_region
}

terraform {
  backend "gcs" {
    bucket  = "terraform-state-proum-coreos-assemble"
    prefix  = "github"
  }
}

data "google_project" "assembler" {
  project_id = var.gcp_project
}

data "google_service_account" "assembler" {
  account_id = "assembler"
  project    = data.google_project.assembler.project_id
}

data "google_compute_image" "assembler-image" {
  name      = "proum-coreos-assembler"
  project   = data.google_project.assembler.project_id
}

resource "google_compute_instance" "assembler" {
  name         = "proum-coreos-assembler"

  min_cpu_platform = var.min_cpu_platform
  machine_type     = var.machine_type

  zone             = var.gcp_zone
  project          = data.google_project.assembler.project_id

  boot_disk {
    initialize_params {
      image = data.google_compute_image.assembler-image.id
    }
  }

  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
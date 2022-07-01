terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.27.0"
    }
  }
}

provider "google" {
  project     = var.project.name
  region      = var.region.name
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.default.id
  instance = google_compute_instance.default.id
}

resource "google_compute_disk" "default" {
 project = var.project.name
 name = var.disk.name
 zone = var.zone.name
 size = 80
}

resource "google_compute_instance" "default" {
  name         = var.instance.name
  machine_type = "e2-standard-4"
  zone         = var.zone.name
  tags = ["ssh"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size = 80
    }
  }

 lifecycle {
    ignore_changes = [attached_disk]
  }

  network_interface {
    network       = "default"
    access_config { }
  }
  metadata_startup_script = "sudo apt update -y && sudo apt upgrade -y"
}

resource "google_compute_firewall" "allow-ssh" {
  name    = var.rule_name
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ssh"]
}

output "connect" {
    value = "gcloud compute ssh --zone ${google_compute_instance.default.zone} ${google_compute_instance.default.name} --project ${google_compute_instance.default.project}"
}

terraform {
  required_version = "~> 1.0.11"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.60.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}


resource "google_compute_network" "rstudio_network" {
    name           = "rstudio-network"    
}

# Allow http/s and ssh into that machine
resource "google_compute_firewall" "rstudio_firewll" {
  name    = "jupyter-firewall"
  network = google_compute_network.rstudio_network.name

  allow {
    protocol                 = "tcp"
    ports                    = ["80", "443", "8787", "22"]
  }

  target_tags = ["rstudio-firewall"]
}

resource "random_id" "instance_name_suffix" {
  byte_length = 4
}


resource "google_dns_record_set" "set" {
  name         = "${var.domain}."
  type         = "A"
  ttl          = 10
  managed_zone = var.managed_dns_zone
  rrdatas      = [google_compute_instance.rstudio.network_interface.0.access_config.0.nat_ip]
}

resource "google_compute_instance" "rstudio" {
  name                    = "rstudio-${random_id.instance_name_suffix.hex}"
  machine_type            = var.rstudio_machine_config.machine_type
  tags                    = ["rstudio-firewall"]


  metadata_startup_script = templatefile("rstudio_provision.sh", 
    { 
      domain=var.domain,
      admin_email=var.admin_email
    }
  )

  boot_disk {
    initialize_params {
      image = var.rstudio_os_image
      size = var.rstudio_machine_config.disk_size_gb
    }
  }

  network_interface {
    network = google_compute_network.rstudio_network.name
    access_config {
      // creates a public IP
    }
  }
}

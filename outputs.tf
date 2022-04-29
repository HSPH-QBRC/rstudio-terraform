output "rstudio_ip" {
    value = google_compute_instance.rstudio.network_interface.0.access_config.0.nat_ip
}

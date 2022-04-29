variable "project_id" {
  description = "GCP project ID"
}

variable "credentials_file" {
  description = "Path to JSON file with GCP service account key"
}

variable "region" {
  default = "us-east4"
}

variable "zone" {
  default = "us-east4-c"
}

variable "rstudio_machine_config" {
  type    = object({
                machine_type   = string
                disk_size_gb   = number
            })
}

variable "rstudio_os_image" {
    default = "ubuntu-2110-impish-v20220309"
}

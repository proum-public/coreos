variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "europe-west1"
}

variable "gcp_zone" {
  type        = string
  description = "Zone in GCP region"
  default     = "europe-west1-b"
}

variable "gcp_project" {
  type        = string
  description = "GCP project name"
  default     = "proum-coreos-assemble"
}

variable "min_cpu_platform" {
  type        = string
  description = "Minimum CPU platform"
  default     = "cascadelake"
}

variable "machine_type" {
  type        = string
  description = "GCP Machine Type"
  default     = "c2-standard-4"
}
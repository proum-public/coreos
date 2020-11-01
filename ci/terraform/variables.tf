variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "europe-west1"
}

variable "gcp_project" {
  type        = string
  description = "GCP project name"
}

variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
}

variable "storage-class" {
  type        = string
  description = "The storage class of the Storage Bucket to create"
  default     = "REGIONAL"
}
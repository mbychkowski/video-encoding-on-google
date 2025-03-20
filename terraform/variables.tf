variable "project_id" {
  description = "Unique project id for your Google Cloud project where resources will be created."
  type        = string
}

variable "customer_id" {
  description = "ID to be added to all resources that will be created."
  type        = string
  default     = "gcp"
}

variable "region" {
  description = "Region to be added to all resources that will be created."
  type        = string
  default     = "us-central1"
}

variable "clusters" {
  type = list(string)
  description = "A list of GKE clusters to be created based on regions"
  default = ["us-central1", "us-west1",]
}
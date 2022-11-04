variable "host_project_id" {
  description = "Host project_id that the service project will be attached to"
  type        = string
}

variable "shared_vpcs" {
  type        = list(string)
  description = "List of Shared VPCs that should be queried for available subnetworks"
  default     = []
}
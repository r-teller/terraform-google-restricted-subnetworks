variable "host_project_id" {
  type        = string
  description = "Host Project id of the project that holds the network."
}

variable "shared_vpcs" {
  type        = list(string)
  description = "List of Shared VPCs that should be queried for available subnetworks"
  default     = []
}

variable "target_mappings" {
  type = list(object({
    folder_ids  = optional(list(number), null),
    project_ids = optional(list(string)),
    subnet_match = optional(object({
      subnetwork = optional(object({
        regex = optional(string)
      })),
      region = optional(object({
        regex = optional(string)
      })),
      network = optional(object({
        regex = optional(string)
      }))
    })),
    subnet_list = optional(list(string))
    })
  )
  validation {
    error_message = "At least one value is required in either folder_ids(list(number)) or project_ids(list(string))"
    condition     = contains([for key in var.target_mappings : anytrue([try(length(key.project_ids) > 0, false), try(length(key.folder_ids) > 0, false)])], true)
  }
}


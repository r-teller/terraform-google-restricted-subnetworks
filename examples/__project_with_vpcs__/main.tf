locals {
  targets_path = "./targets"

  targets_sets = fileset(local.targets_path, "*")
  target_mappings = flatten([for targets in local.targets_sets : [
    jsondecode(file("${local.targets_path}/${targets}"))
    ]
  ])
}

module "restricted_subnetworks" {
  source  = "r-teller/restricted_subnetworks/google"
  version = ">=0.0.0"

  target_mappings = local.target_mappings
  host_project_id = var.host_project_id
}



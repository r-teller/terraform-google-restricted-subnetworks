locals {
  data_subnetworks_list = flatten([for value in flatten(values(data.google_compute_network.networks)[*]) : [
    for subnetwork_self_link in value.subnetworks_self_links : {

      name       = regex("projects/.*/regions/.*/subnetworks/(?P<name>[^$]*)", subnetwork_self_link).name
      network    = regex("projects/.*/networks/(?P<network>[^$]*)", value.id).network
      region     = regex("projects/.*/regions/(?P<region>[^/]*)/*", subnetwork_self_link).region
      selfLink   = subnetwork_self_link
      subnetwork = regex("projects/.+", subnetwork_self_link)
    }
    ]
  ])

  subnetworks_list = length(var.shared_vpcs) > 0 ? local.data_subnetworks_list : flatten(module.subnetworks_list.*.subnetworks)
}

data "google_compute_network" "networks" {
  for_each = toset(var.shared_vpcs)
  name     = each.key
  project  = var.host_project_id
}


module "subnetworks_list" {
  count  = length(var.shared_vpcs) > 0 ? 0 : 1
  source = "./modules/subnetworks_list"

  project_id = var.host_project_id
}

## Example
## https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_organization_policy
resource "google_project_organization_policy" "project_shared_vpc_restrict_subnetworks" {
  for_each   = local.merge_target_project_ids
  project    = each.key
  constraint = "compute.restrictSharedVpcSubnetworks"

  list_policy {
    allow {
      values = each.value
    }
  }
}

## https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_organization_policy
resource "google_folder_organization_policy" "folder_shared_vpc_restrict_subnetworks" {
  for_each   = local.merge_target_folder_ids
  folder     = each.key
  constraint = "compute.restrictSharedVpcSubnetworks"

  list_policy {
    allow {
      values = each.value
    }
  }
}

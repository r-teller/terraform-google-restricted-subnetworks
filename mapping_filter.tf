locals {
  ## Parses output from subnetworks_list module to create map of subnets and add additional flags for future filtering
  ### Filters can be one or more of the following Subnetwork, Region and Network. All filters are treated as AND
  target_subnetwork_mappings = flatten([
    for target in var.target_mappings : [
      for subnetwork in local.subnetworks_list : {
        folder_ids  = target.folder_ids
        project_ids = target.project_ids

        subnetwork        = subnetwork.subnetwork
        subnetwork_filter = try(target.subnet_match.subnetwork.regex != null, false) ? length(regexall(target.subnet_match.subnetwork.regex, subnetwork.selfLink)) > 0 ? "true" : "false" : "na"
        subnetwork_regex  = try(target.subnet_match.subnetwork.regex != null, false) ? target.subnet_match.subnetwork.regex : "na"

        region        = subnetwork.region
        region_filter = try(target.subnet_match.region.regex != null, false) ? length(regexall(target.subnet_match.region.regex, subnetwork.region)) > 0 ? "true" : "false" : "na"
        region_regex  = try(target.subnet_match.region.regex != null, false) ? target.subnet_match.region.regex : "na"

        network        = subnetwork.network
        network_filter = try(target.subnet_match.network.regex != null, false) ? length(regexall(target.subnet_match.network.regex, subnetwork.network)) > 0 ? "true" : "false" : "na"
        network_regex  = try(target.subnet_match.network.regex != null, false) ? target.subnet_match.network.regex : "na"
      }
    ]
  ])

  ## Parses output from subnetworks_list module to filter out subnets that do not match the regex specified in the target JSON file
  filter_target_subnetwork_mappings = [
    for target in local.target_subnetwork_mappings : {
      folder_ids  = target.folder_ids
      project_ids = target.project_ids
      subnetwork  = target.subnetwork
    } if(target.subnetwork_filter != "false" && target.region_filter != "false" && target.network_filter != "false") && (target.subnetwork_filter != "na" || target.region_filter != "na" || target.network_filter != "na")
  ]

  additional_target_subnetwork_mappings = flatten([
    for target in var.target_mappings : [
      for subnet in target.subnet_list : {
        folder_ids  = target.folder_ids
        project_ids = target.project_ids
        subnetwork  = subnet
      }
    ] if target.subnet_list != null
  ])

  concat_target_subnetwork_mappings = concat(local.filter_target_subnetwork_mappings, local.additional_target_subnetwork_mappings)
}

# Shared VPC Restricted Subnetworks
This solution is comprised of two terriform modules. The restricted_subnetworks module is used to dynamically define which subnetworks are allowed based regex matching and is applied at either the Service-Project or Folder Hiearchy. The subnetworks_list module queries GCP API(s) for the specified Host Project (var.host_project_id) and discover all configured subnetworks within the specified Host Project. 

The subnetworks to project/folder mapping should be defined at the Host Project level to reduce the touchpoints required to update organization policies when subnetworks are added or removed. With the targets directory of the Host Project JSON files are used to define which subnets should be allowed based on regex matching (Subnetwork, Region and Network)

>*Note:* If you do not pass in a variable for `shared_vpcs` the `modules\subnetworks_list` is used to dynamically discover the list of available VPCs.


## Hierarchy
Example:
```
|---modules
    |---subnetworks_list    
\---projects
    +---project-alpha-aaaa
        |   main.tf
        |   terraform.tf
        |   terraform.tfvars
        |   variables.tf
        |
        \---targets
                target-aaa.json
                target-bbb.json
                target-ccc.json
```

```
## terraform.tfvars for dynamic discovery of subnets
# examples\__project_without_vpcs__
host_project_id     = "my-host-project"
```

```
## terraform.tfvars for discovery of subnets within specific vpcs
# examples\__project_with_vpcs__
host_project_id     = "my-host-project"
shared_vpcs         = ["my-vpc-alpha", "my-vpc-bravo"]
```


# Root Folder Search Syntax
This snippet will allow you to quickly find all folder ids based on the folder displayName and a specified root search folder id
```bash
## Search for the Root Folder based on DisplayName
gcloud asset search-all-resources --scope='organizations/111111111111' \
  --asset-types='cloudresourcemanager.googleapis.com/Folder' \
  --query='displayName="Enterprise Data Lake"' \
  --format='table(name)' | awk -F / '{print $NF}'

## Search within the Root Folder from above based on DisplayName
gcloud asset search-all-resources \
  --scope='folders/111111111111' \
  --asset-types='cloudresourcemanager.googleapis.com/Folder' \
  --query='displayName=(Dev OR FDev OR DDev)' \
  --format='csv[no-heading](name)' | awk -F / '{print $NF}' | tr '\n' ','
```


## Useful Links
- https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints#constraints-for-specific-services
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_organization_policy
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_organization_policy
- https://www.terraform.io/docs/language/functions/regex.html

Shared VPC connects projects within the same organization. Participating host and service projects cannot belong to different organizations. Linked projects can be in the same or different folders, but if they are in different folders the admin must have Shared VPC Admin rights to both folders. Refer to the Google Cloud resource hierarchy for more information about organizations, folders, and projects.
- https://cloud.google.com/vpc/docs/shared-vpc

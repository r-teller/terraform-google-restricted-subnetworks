#!/bin/bash
tf plan -out=tfplan > /dev/null
folder_count=`tf show -json tfplan | jq '.output_changes.restricted_folder_id_subnetworks.after[0]' | jq 'keys' | jq length`
subnet_count=`tf show -json tfplan | jq '.output_changes.restricted_folder_id_subnetworks.after[0][][]' | wc -l`
host_project_id=`tf show -json tfplan | jq -r '.variables.host_project_id.value'`
subnetwork_count=`gcloud compute networks subnets list --project $host_project_id --format='csv[no-heading](name)' | wc -l`

echo "Folder Count = $folder_count"
echo "Subnet Count = $subnet_count"
echo "Subnetwork Count = $subnetwork_count"
rm tfplan
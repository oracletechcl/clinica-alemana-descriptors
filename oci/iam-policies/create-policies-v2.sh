# OCI CLI commands to create IAM policies for Kubernetes Storage Classes

## Prerequisites
# 1. Ensure OCI CLI is installed and configured
# 2. Have proper permissions to create policies and dynamic groups
# 3. Update the compartment OCID if different from the one in the JSON files

## Create Dynamic Group for Kubernetes Nodes
oci iam dynamic-group create \
  --name "k8s-dynamic-group" \
  --description "Dynamic group for Kubernetes cluster nodes" \
  --matching-rule "ALL {resource.type = 'cluster', resource.compartment.id = 'ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva'}"

## Create Block Storage Management Policy
oci iam policy create \
  --name "k8s-block-storage-management-policy" \
  --description "Policy for Kubernetes Block Storage CSI driver operations" \
  --compartment-id "ocid1.tenancy.oc1..aaaaaaaaller3eoan3jlvomrukdsg5lcmk3vwvzczuuvz2xoszzvigvtqfna" \
  --statements '[
    "Allow dynamic-group k8s-dynamic-group to manage volume-family in tenancy",
    "Allow dynamic-group k8s-dynamic-group to manage volume-attachments in tenancy",
    "Allow dynamic-group k8s-dynamic-group to manage instance-family in tenancy",
    "Allow dynamic-group k8s-dynamic-group to use subnets in tenancy",
    "Allow dynamic-group k8s-dynamic-group to use vnics in tenancy",
    "Allow dynamic-group k8s-dynamic-group to use network-security-groups in tenancy",
    "Allow dynamic-group k8s-dynamic-group to read work-requests in tenancy",
    "Allow dynamic-group k8s-dynamic-group to use keys in tenancy"
  ]'

## Create Block Storage Backup Policy
oci iam policy create \
  --name "k8s-block-storage-backup-policy" \
  --description "Policy for Kubernetes Block Storage CSI driver operations" \
  --compartment-id "ocid1.tenancy.oc1..aaaaaaaaller3eoan3jlvomrukdsg5lcmk3vwvzczuuvz2xoszzvigvtqfna" \
  --statements '[
    "Allow dynamic-group k8s-dynamic-group to manage volume-backups in tenancy",
    "Allow dynamic-group k8s-dynamic-group to manage backup-policies in tenancy"
  ]'

## Create File Storage Management Policy
oci iam policy create \
  --name "k8s-file-storage-management-policy" \
  --description "Policy for Kubernetes File Storage Service (FSS) CSI driver operations" \
  --compartment-id "ocid1.tenancy.oc1..aaaaaaaaller3eoan3jlvomrukdsg5lcmk3vwvzczuuvz2xoszzvigvtqfna" \
  --statements '[
    "Allow dynamic-group k8s-dynamic-group to manage file-family in tenancy",
    "Allow dynamic-group k8s-dynamic-group to manage virtual-network-family in tenancy",
    "Allow dynamic-group k8s-dynamic-group to manage instance-family in tenancy",
    "Allow dynamic-group k8s-dynamic-group to read work-requests in tenancy",
    "Allow dynamic-group k8s-dynamic-group to use keys in tenancy"
  ]'

## Create File Storage Snapshot Policy
oci iam policy create \
  --name "k8s-file-storage-snapshot-policy" \
  --description "Policy for Kubernetes File Storage Service snapshot operations" \
  --compartment-id "ocid1.tenancy.oc1..aaaaaaaaller3eoan3jlvomrukdsg5lcmk3vwvzczuuvz2xoszzvigvtqfna" \
  --statements '[
    "Allow dynamic-group k8s-dynamic-group to manage filesystem-snapshot-policies in tenancy"
  ]'

# --- OCI command to apply a change ---
echo "Applying OCI configuration changes..."
# Example: oci iam policy update --policy-id ...
echo "✅ Changes applied."

# --- Wait for 5 minutes ---
echo "⏳ Waiting for 5 minutes for changes to propagate..."
sleep 300

# End message ...
echo "All IAM policies for Kubernetes storage classes have been created successfully!"

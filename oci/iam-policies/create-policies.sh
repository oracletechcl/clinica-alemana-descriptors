# OCI CLI commands to create IAM policies for Kubernetes Storage Classes

## Prerequisites
# 1. Ensure OCI CLI is installed and configured
# 2. Have proper permissions to create policies and dynamic groups
# 3. Update the compartment OCID if different from the one in the JSON files

## Create Dynamic Group for Kubernetes Nodes
oci iam dynamic-group create \
  --name "k8s-nodes" \
  --description "Dynamic group for Kubernetes cluster nodes" \
  --matching-rule "ALL {instance.compartment.id = 'ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva'}"

## Create Block Storage Management Policy
oci iam policy create \
  --name "k8s-block-storage-management-policy" \
  --description "Policy for Kubernetes Block Storage CSI driver operations" \
  --compartment-id "ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva" \
  --statements '[
    "Allow dynamic-group k8s-nodes to manage volume-family in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to manage volume-attachments in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to manage instances in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to read compartments in tenancy",
    "Allow dynamic-group k8s-nodes to read availability-domains in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to use subnets in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to use vnics in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to use network-security-groups in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva"
  ]'

## Create Block Storage Backup Policy
oci iam policy create \
  --name "k8s-block-storage-backup-policy" \
  --description "Policy for Kubernetes Block Storage backup operations" \
  --compartment-id "ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva" \
  --statements '[
    "Allow dynamic-group k8s-nodes to manage volume-backups in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to manage volume-backup-policies in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva"
  ]'

## Create File Storage Management Policy
oci iam policy create \
  --name "k8s-file-storage-management-policy" \
  --description "Policy for Kubernetes File Storage Service (FSS) CSI driver operations" \
  --compartment-id "ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva" \
  --statements '[
    "Allow dynamic-group k8s-nodes to manage file-family in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to manage mount-targets in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to manage export-sets in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to manage file-systems in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to read compartments in tenancy",
    "Allow dynamic-group k8s-nodes to read availability-domains in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to use subnets in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to use vnics in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva",
    "Allow dynamic-group k8s-nodes to use network-security-groups in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva"
  ]'

## Create File Storage Snapshot Policy
oci iam policy create \
  --name "k8s-file-storage-snapshot-policy" \
  --description "Policy for Kubernetes File Storage Service snapshot operations" \
  --compartment-id "ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva" \
  --statements '[
    "Allow dynamic-group k8s-nodes to manage file-system-snapshots in compartment id ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva"
  ]'

echo "All IAM policies for Kubernetes storage classes have been created successfully!"

#!/bin/bash

# --- Standard OKE initialization template ---
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh

# This script is executed by cloud-init on the first boot of a new OKE node.
# It expands the root filesystem and logs the output.
LOG_FILE="/var/log/custom_node_setup.log"

# Run the oci-growfs command with the -y flag for non-interactive execution.
# We redirect both standard output (stdout) and standard error (stderr) to the log file.
echo "Attempting to expand the root filesystem..." >> $LOG_FILE
#sudo dd iflag=direct if=/dev/sda of=/dev/null count=1
sudo /usr/libexec/oci-growfs -y >> $LOG_FILE 2>&1

# Log the final state of the filesystem for easy verification.
echo "Filesystem expansion complete. Final disk usage:" >> $LOG_FILE
df -h / >> $LOG_FILE

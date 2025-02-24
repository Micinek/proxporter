#!/bin/bash
# This script exports assigned CPU, RAM, and disk sizes from Proxmox QEMU VMs and LXC Containers.
# It ignores any snapshot configuration sections that appear after a line starting with '['.

CSV_FILE="proxporter.csv"

# Write CSV header
echo "Type,Node,ID,Name,Assigned CPU,Assigned RAM (MB),Disks" > "$CSV_FILE"

# Process QEMU VMs
for NODE_DIR in /etc/pve/nodes/*; do
    if [ -d "$NODE_DIR/qemu-server" ]; then
        NODE=$(basename "$NODE_DIR")
        for CONF in "$NODE_DIR/qemu-server/"*.conf; do
            [ -e "$CONF" ] || continue  # Skip if no conf files

            # Filter out snapshot info: only read until first line that starts with '['.
            CONFIG_CONTENT=$(sed '/^\[/q' "$CONF")

            VMID=$(basename "$CONF" .conf)
            VM_NAME=$(echo "$CONFIG_CONTENT" | grep -E "^name:" | head -1 | cut -d':' -f2- | sed 's/^[ \t]*//' | tr '\n' ' ')
            VM_CPU=$(echo "$CONFIG_CONTENT" | grep -E "^cores:" | head -1 | cut -d':' -f2- | sed 's/^[ \t]*//')
            VM_MEM=$(echo "$CONFIG_CONTENT" | grep -E "^memory:" | head -1 | cut -d':' -f2- | sed 's/^[ \t]*//')

            # Get disk sizes
            DISK_LINES=$(echo "$CONFIG_CONTENT" | grep -E "^(virtio|scsi|sata|ide)[0-9]+:")
            DISKS=""
            while IFS= read -r disk_line; do
                key=$(echo "$disk_line" | cut -d':' -f1)
                size=$(echo "$disk_line" | grep -o "size=[^,]*" | cut -d'=' -f2)
                if [ -z "$size" ]; then size="N/A"; fi
                DISKS="${DISKS}${key}: ${size}; "
            done <<< "$DISK_LINES"

            if [ -z "$DISKS" ]; then DISKS="N/A"; fi

            # Append VM data to CSV
            echo "VM,$NODE,$VMID,\"$VM_NAME\",$VM_CPU,$VM_MEM,\"$DISKS\"" >> "$CSV_FILE"
        done
    fi
done

# Process LXC Containers (using /etc/pve/nodes/*/lxc/)
for NODE_DIR in /etc/pve/nodes/*; do
    if [ -d "$NODE_DIR/lxc" ]; then
        NODE=$(basename "$NODE_DIR")
        for CONF in "$NODE_DIR/lxc/"*.conf; do
            [ -e "$CONF" ] || continue  # Skip if no conf files

            # Filter out snapshot info
            CONFIG_CONTENT=$(sed '/^\[/q' "$CONF")

            CTID=$(basename "$CONF" .conf)
            CT_NAME=$(echo "$CONFIG_CONTENT" | grep -E "^hostname:" | head -1 | cut -d':' -f2- | sed 's/^[ \t]*//' | tr '\n' ' ')
            CT_CPU=$(echo "$CONFIG_CONTENT" | grep -E "^cores:" | head -1 | cut -d':' -f2- | sed 's/^[ \t]*//')
            CT_MEM=$(echo "$CONFIG_CONTENT" | grep -E "^memory:" | head -1 | cut -d':' -f2- | sed 's/^[ \t]*//')

            # Get disk sizes (rootfs and other mount points)
            DISK_LINES=$(echo "$CONFIG_CONTENT" | grep -E "^(mp[0-9]+|rootfs):" | uniq)
            DISKS=""
            while IFS= read -r disk_line; do
                key=$(echo "$disk_line" | cut -d':' -f1)
                size=$(echo "$disk_line" | grep -o "size=[^,]*" | cut -d'=' -f2)
                if [ -z "$size" ]; then size="N/A"; fi
                DISKS="${DISKS}${key}: ${size}; "
            done <<< "$DISK_LINES"

            if [ -z "$DISKS" ]; then DISKS="N/A"; fi

            # Append LXC data to CSV
            echo "LXC,$NODE,$CTID,\"$CT_NAME\",$CT_CPU,$CT_MEM,\"$DISKS\"" >> "$CSV_FILE"
        done
    fi
done

echo "Export complete. CSV saved as $CSV_FILE"

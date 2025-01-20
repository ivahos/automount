#!/bin/bash

# Replace with your volume's UUID
VOLUME_UUID="REPLACE_THIS_WITH_YOUR_UUID"

# Function to mount the disk
mountdisk() {
    # Wait for the volume to come online
    while :; do
        echo "Looking for disk..."
        
        # Check if the volume with the specified UUID exists
        diskutil apfs list | grep "$VOLUME_UUID" > /dev/null
        
        # If the volume is found, break the loop
        if [ $? -eq 0 ]; then
            echo "Volume found."
            break
        fi

        # If not found, wait for 1 second before retrying
        echo "Volume not found at $(date). Retrying in 1 second..."
        sleep 1
    done

    # Unlock and mount the encrypted disk
    echo "Unlocking and mounting the volume..."
    diskutil apfs unlockVolume "$VOLUME_UUID" -passphrase "put_your_disk_password_here"
}

# Main script logic
while :; do
    # Start by waiting for and mounting the external drive
    mountdisk

    # Monitor the volume to ensure it remains mounted
    while :; do
        sleep 1

        # Get the "Mounted" status of the volume
        MOUNTED_STATUS=$(diskutil info "$VOLUME_UUID" | grep "Mounted" | awk '{print $2}')

        # If the volume is still mounted, continue monitoring
        if [[ "$MOUNTED_STATUS" == "Yes" ]]; then
            continue
        else
            # If the volume becomes unmounted, break the loop and attempt to remount
            echo "Disk has become unmounted. Attempting to remount..."
            break
        fi
    done
done

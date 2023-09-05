#!/bin/bash

# Check if the image file parameter is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <image_file>"
  exit 1
fi

image_file="$1"

# Get the disk information using sudo fdisk -l and grep
disk_info=$(sudo fdisk -l | grep "Disk /dev/sd")

# Check if there are any disks found
if [ -z "$disk_info" ]; then
  echo "No disks found."
  exit 1
fi

# Extract the device names and present them to the user
echo "$disk_info"
devices=($(echo "$disk_info" | awk -F'[: ]+' '{print $2}'))

# Present the options to the user
PS3="Select a device: "
select choice in "${devices[@]}" "Quit"; do
  case "$choice" in
    "Quit")
      echo "Exiting..."
      exit 0
      ;;
    *)
      selected_device="$choice"
      break
      ;;
  esac
done

echo "Now image $image_file will be written to: $selected_device"

while true; do
  echo "Do you want to continue? (yes/no): "
  read response
  if [[ "$response" == "yes" ]]; then
    start_time=$(date +%s)
    umount ${selected_device}1
    umount ${selected_device}2
    dd if="$image_file" of=$selected_device bs=1M status=progress conv=fsync
    end_time=$(date +%s)
    time_spent=$((end_time - start_time))
    echo "Image has written. Time spent: $time_spent seconds"

    
    #expand file system to full sdcard size
    echo "Expanding file system to full sdcard size. Please wait..."
    parted $selected_device resizepart 2 100%
    e2fsck -f ${selected_device}2
    resize2fs ${selected_device}2

    break  
  elif [[ "$response" == "no" ]]; then
    echo "You chose NO. EXIT."
    break  
  else
    echo "Invalid response. Please enter 'yes' or 'no'."
  fi
done

echo "Image is writing now. DO NOT REMOVE SDCARD!"
echo
echo "Wait for blue led stops flashing."
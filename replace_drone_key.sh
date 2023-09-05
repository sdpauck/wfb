#!/bin/bash

# Check if the image file parameter is provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <image_file> <path-to-drone.key>"
  exit 1
fi

# Path to the combined multipart disk image file
image_file="$1"
key_file="$2"
# Directory where you want to mount the image
mount_point="/mnt/mountpoint"

# Check if the image file exists
if [ ! -f "$image_file" ]; then
  echo "Error: The image file '$image_file' does not exist."
  exit 1
fi

# Check if the key file exists
if [ ! -f "$key_file" ]; then
  echo "Error: The key file '$key_file' does not exist."
  exit 1
fi

# Check if the mount point exists, and if not, create it
if [ ! -d "$mount_point" ]; then
  mkdir -p "$mount_point"
fi

# Mount the disk image using the loop device
loopdev=`losetup --partscan --find --show $image_file`

mount ${loopdev}p2 /mnt/mountpoint/
# Check if the mounting was successful
if [ $? -eq 0 ]; then
  echo "device: ${loopdev}p2"

  echo "Disk image mounted at: $mount_point"
else
  echo "Error: Failed to mount the disk image."
  exit 1
fi

cp "$key_file" $mount_point/etc/

if [ $? -eq 0 ]; then
  echo "new key uploaded"
else
  echo "Error: Failed to cop-y key."
  exit 1
fi

# Unmount the disk image
sudo umount "$mount_point"
losetup -d "$loopdev"



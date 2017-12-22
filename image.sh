#!/bin/bash -e

if [ ! -f /tmp/raspbian/.setup ]; then
  echo "Fetching image"
  mkdir -p /tmp/raspbian

  curl -L https://downloads.raspberrypi.org/raspbian_lite_latest > /tmp/raspbian/image.zip
  unzip /tmp/raspbian/image.zip -d /tmp/raspbian
  touch /tmp/raspbian/.setup
fi

image=`find /tmp/raspbian/*.img`


echo "Finding SD card"
diskutil list

read -p "Identify your sd card's disk. (e.g. disk5) " < /dev/tty
echo
disk=$REPLY

echo "Unmounting $disk"
diskutil unmountDisk /dev/$disk

echo "Imaging $image to $disk (don't exit. It wouldn't stop the process)"
sudo dd bs=1m if=$image of=/dev/$disk conv=sync &

while :;do
  sudo killall -INFO dd || break
  sleep 1
done

echo "Enabling SSH"
diskutil mountDisk /dev/$disk
touch /Volumes/boot/ssh

echo "Ejecting $disk"
sudo diskutil eject /dev/$disk
echo "All done!"

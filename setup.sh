#!/bin/sh
#
# For installing NixOS having booted from the minimal USB image.
#
# To run:
#
#     sh -c "$(curl https://eipi.xyz/nixinst.sh)"
#
# https://eipi.xyz/blog/nixos-x86-64

if [ $(whoami) != "root" ]; then
    echo "not root"
    exit;
fi

echo "--------------------------------------------------------------------------------"
echo "Your attached storage devices will now be listed."
echo "--------------------------------------------------------------------------------"
echo "Detected the following devices:"
echo

i=0
for device in $(fdisk -l | grep "^Disk /dev" | awk "{print \$2}" | sed "s/://"); do
    echo "[$i] $device"
    i=$((i+1))
    DEVICES[$i]=$device
done

echo
read -p "Which device do you wish to install on? " DEVICE

DEV=${DEVICES[$(($DEVICE+1))]}

read -p "How much swap space do you need in GiB (e.g. 8)? " SWAP

read -p "Will now partition ${DEV} with swap size ${SWAP}GiB. Ok? Type 'y': " ANSWER

if [ "$ANSWER" = "y" ]; then
    echo "partitioning ${DEV}..."
    (
      echo g # new gpt partition table

      echo n # new partition
      echo 3 # partition 3
      echo   # default start sector
      echo +512M # size is 512M

      echo n # new partition
      echo 1 # first partition
      echo   # default start sector
      echo -${SWAP}G # last N GiB

      echo n # new partition
      echo 2 # second partition
      echo   # default start sector
      echo   # default end sector

      echo t # set type
      echo 1 # first partition
      echo 20 # Linux Filesystem

      echo t # set type
      echo 2 # first partition
      echo 19 # Linux swap

      echo t # set type
      echo 3 # first partition
      echo 1 # EFI System

      echo p # print layout

      echo w # write changes
    ) | fdisk ${DEV}
else
    echo "cancelled."
    exit
fi

echo "--------------------------------------------------------------------------------"
echo "checking partition alignment..."

function align_check() {
    (
      echo
      echo $1
    ) | parted $DEV align-check | grep aligned | sed "s/^/partition /"
}

align_check 1
align_check 2
align_check 3

echo "--------------------------------------------------------------------------------"
echo "getting created partition names..."

i=1
for part in $(fdisk -l | grep $DEV | grep -v "," | awk '{print $1}'); do
    echo "[$i] $part"
    i=$((i+1))
    PARTITIONS[$i]=$part
done

P1=${PARTITIONS[2]}
P2=${PARTITIONS[3]}
P3=${PARTITIONS[4]}

echo "--------------------------------------------------------------------------------"
read -p "Press enter to install NixOS." NULL

echo "making filesystem on ${P1}..."

mkfs.ext4 -L nixos ${P1}

echo "enabling swap..."

mkswap -L swap ${P2}
swapon ${P2}

echo "making filesystem on ${P3}..."

mkfs.fat -F 32 -n boot ${P3}            # (for UEFI systems only)

echo "mounting filesystems..."

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot                      # (for UEFI systems only)
mount /dev/disk/by-label/boot /mnt/boot # (for UEFI systems only)

echo "generating NixOS configuration..."

nixos-generate-config --root /mnt

cat /etc/config.nix > /mnt/etc/nixos/configuration.nix

echo "copying custom packages"
cp -r /etc/foxdot.nix /mnt/etc/nixos/foxdot.nix

echo "installing NixOS..."

nixos-install

echo "run any scripts inside new system then 'exit' to exit"

nixos-enter

read -p "Remove installation media and press enter to reboot." NULL

reboot
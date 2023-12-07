#! /bin/bash

set -e
cd $(dirname $0)/..

source="$1"
target="$2"
mount_path=$(sudo mktemp -d -p /mnt --suffix -flatcar)

if [ ! -f "$source" ]; then
	echo "cannot find source image $source"
	exit 1
fi

if [ ! -f "afterburn" ]; then
	echo "cannot find prebuilt afterburn binary (at ./afterburn)"
	exit 1
fi

function convert_to_raw_image {
	echo "> converting $source to raw image"
	qemu-img convert -f qcow2 -O raw "$source" "$source.bin"
}

function convert_to_qcow2_image {
	echo "> converting $source.bin to qcow2 image"
	qemu-img convert -f raw -O qcow2 "$source.bin" "$target"
}

function mount_partition {
	echo "> mounting partition $1 to $2"
	# PART can be 1 (boot), 6 (OEM), 9 (ROOT)
	export PART=$1
	export LOOP=$(sudo losetup --partscan --find --show "$source.bin")
	sudo mount "${LOOP}p${PART}" "$2"
}

function umount_partition {
	echo "> unmounting partition $PART"
	sudo umount "$1"
	# sudo losetup -d "$LOOP"
}

function copy_files {
	echo "> copying files to OEM partition"
	sudo cp -r ./oem/* "$mount_path"
	sudo mkdir -p "$mount_path/bin"
	sudo cp ./afterburn "$mount_path/bin/afterburn"
}

function cleanup {
	echo "> cleaning up"
	sudo rm -rf "$mount_path"
	rm -f "$source.bin"
}

convert_to_raw_image
mount_partition 6 "$mount_path"
copy_files
umount_partition "$mount_path"
convert_to_qcow2_image
cleanup

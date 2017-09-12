#!/bin/bash

notify() {
	echo -ne "\e[1m[\e[31mKernel-Update\e[0m\e[1m] "
	echo -n "$1"
	echo -e "\e[0m"
}

# Abort on error
set -e

# Remove old kernel sources
emerge -q --noreplace eclean-kernel

if [ "$(eix '-I*' --format '<installedversions:NAMEVERSION>' gentoo-sources | wc -l)" -ne "1" ]; then
	notify "Removing old kernel sources..."
	emerge --depclean || exit 1
fi

# Select most current
eselect kernel set 1

# Check if an upgrade is needed.
new_kernel=$(readlink /usr/src/linux | sed 's/linux-//g')
current_kernel=$(uname -r)
if [ "$new_kernel" == "$current_kernel" ]; then
	# A kernel based on the most recent sources is already running
	notify "No upgrade needed."
	exit 0
fi

# Upgrade is needed, continue....
pushd /usr/src/linux

# Copy old config
notify "Upgrading to: $new_kernel"
cp -v /usr/src/linux-$current_kernel/.config .

# Create new config
yes "" | make oldconfig

# Compile
make -j5

# Install
make install
make modules_install
boot-update

# Rebuild modules
notify "Rebuilding modules..."
emerge -v @module-rebuild

# Remove old kernel stuff
notify "Removing old kernels..."
eclean-kernel --destructive -n 2
boot-update

exit 0

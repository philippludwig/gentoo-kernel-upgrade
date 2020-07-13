# gentoo-kernel-upgrade
This is a script for updating your kernel of your Gentoo/Funtoo system in
an automatic way.
You can schedule this script using cron or run it manually.

## Requirements
This script makes a few assumptions about your system:

* You have ``eix`` installed.
* You are using ``gentoo-sources`` **only**,
* Your sources live under ``/usr/src``
* **Important**: You don't care about old kernels in ``boot``, ``/lib/modules`` and ``/usr/src`` (they will be deleted).

## Usage
    git clone https://github.com/philippludwig/gentoo-kernel-upgrade.git
    sudo gentoo-kernel-upgrade/kernel-update.sh

## How it works
The script performs the following actions (in this order):

1. ``emerge eclean-kernel`` (for removing old kernels)
2. ``emerge --depclean gentoo-sources`` (remove old kernel versions)
3. ``eselect kernel set 1`` (select the most recent source)
4. Check if an upgrade is needed -> if not, do nothing
5. Copy the ``.config`` of your currently running kernel
6. Update config: ``make olddefconfig``
7. Compile your new kernel
8. Install it
9. Re-install kernel modules: ``emerge -v @module-rebuild``
10. Remove old kernels: ``eclean-kernel --destructive -n 2``
11. Run genkernel to create an initramfs.
12. Run ``boot-update`` or ``grub-mkconfig`` to make the new kernel available in your bootloader.

## TODO/Known issues
The following points could be improved about the script:

* Support other kernel source packages than ``gentoo-sources``

Any contributions are welcome!

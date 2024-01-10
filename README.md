# Flatcar Proxmox VE cloud image

This repository contains a customized OEM partition for Flatcar that supports Proxmox VE.

## Supported features

- Set hostname
- Write SSH keys
- Write systemd networkd configuration
- Write attributes file (metadata)

## How it works

The following is run on Github Actions :

- Download the latest Flatcar image (stable)
- Mount the OEM partition
- Write the contents of the `oem/` directory into the OEM partition
- Download and include our [forked Afterburn](https://github.com/coreos/afterburn/pull/1023) that supports Proxmox VE
- Bundle the image again and upload it to Github releases.

## What's included in the OEM partition ?

- Ignition configuration file that will write our custom files
- Systemd configuration files that run our modifed version of Afterburn.
- The forked afterburn binary

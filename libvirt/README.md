# Libvirt HOWTO

Now tested with `macOS 10.15.7 Catalina`

## Creating a VM

### Prepare the environment

1. Install required packages with brew using [`./brew-install.sh`](brew-install.sh)
2. Fix libvirt config files with [`./fix-qemu-conf.sh`](fix-qemu-conf.sh). Warning! This script allows access to VM for all users.
3. Launch libvirt services with `sudo libvirt-enable.sh` (you will be prompted your password to
   access `/Library/LaunchDaemons/` directory). Be careful while this step!

### Create a VM
1. Create domain xml and drives (including install media) using [`./example-catalina.sh`](example-catalina.sh)
2. Define domain: `virsh define ./Catalina/catalina.xml`
3. Attach install media for the first
   boot: `virsh attach-device Catalina --file ./Catalina/installmedia.xml --config`
4. Start the VM: `virsh start Catalina`
5. Connect to the VM with VNC: `open vnc://localhost:5942` (password `0000`)
6. Complete installation and shutdown the VM (see [VM Management](#vm-management))

### Launch VM as usual 
1. Start the VM `virsh start Catalina`
2. Connect to the VM with VNC: `open vnc://localhost:5942` (password `0000`)
3. Done!

### Connect from other node via Virtual Machine Manager
1. Configure ssh access without password from user host to qemu host
2. Go "File" -> "Add new connection"
3. Configure in opened dialog
   * "Hypervisor"->  "Custom URI"
   * Fill "Custom URI" field with qemu+ssh://<ssh user>@<host ip or dns name>/system?socket=/usr/local/var/run/libvirt/libvirt-sock


## VM Management

- Start the VM:

  `virsh start Catalina`

- Shutdown the VM using [AppleQEMUGuestAgent](../AppleQEMUGuestAgent) (preferred):

  `virsh shutdown --mode agent Catalina` or just `sudo virsh shutdown Catalina`

- Shutdown the VM: ACPI mode (sometimes does not work, not investigated):

  `virsh shutdown --mode acpi Catalina`

- Destroy the VM:

  `virsh destroy Catalina`

- Describe network interfaces:

  `virsh domifaddr --source agent Catalina`

## Notes

For some reason networking via `virtio-net-pci` does not work properly with Catalina guest.
`vmxnet3` used instead.

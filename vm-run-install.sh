#!/bin/bash
#
# macOS installation script example
#
# For the 1st boot provide '-install' flag
# Set OS version by '-os <OS NAME>' option
# /Applications/Install macOS <OS NAME>.app required!
#

function setVars() {
  # OS name to install
  OS_NAME="Catalina"

  # Don't attach install media image by default
  INSTALL_OS_FLAG="False"

  # Creating drive to install macOS onto
  # 50G is enough for Catalina
  MAIN_DRIVE_IMG="drive.qcow2"
  MAIN_DRIVE_IMG_SIZE="50G"

  # Executables
  QEMU_SYSTEM_X86_64="./qemu/build/qemu-system-x86_64"
  QEMU_IMG="./qemu/build/qemu-img"
  READOSK="./readosk/readosk"
}

function readArgs() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -install)
      INSTALL_OS_FLAG="True"
      ;;

    -os)
      OS_NAME="$2"
      shift
      ;;

    *)
      shift
      ;;
    esac
    shift
  done
}

function loadComponents() {
  # QEMU download and build
  if ! ./qemu-build.sh; then
    echo "QEMU build failed"
    return 1
  fi

  # 'readosk' tool build
  ./readosk-build.sh
  if [[ ! -f "$READOSK" ]]; then
    echo "readosk build failed"
    return 1
  fi

  # QEMU Firmware download
  if ! ./get-firmware.sh; then
    echo "QEMU firmware download failed"
    return 1
  fi
}

function createInstallImg() {
  export OS_NAME
  ./create-install-img.sh
  return $?
}

function createMainDrive() {
  if [[ -f "$MAIN_DRIVE_IMG" ]]; then
    return
  fi

  "$QEMU_IMG" create -f qcow2 "$MAIN_DRIVE_IMG" "$MAIN_DRIVE_IMG_SIZE"
  return $?
}

function bootInstall() {
  if ! createInstallImg; then
    echo "Install image creation failed"
    return 1
  fi

  ./boot.sh -install -qemu "$QEMU_SYSTEM_X86_64" -osk "$($READOSK)"
}

function bootNoInstall() {
  ./boot.sh -qemu "$QEMU_SYSTEM_X86_64" -osk "$($READOSK)"
}

setVars
readArgs "$@"

if ! loadComponents; then
  echo "Required components not present!"
  exit 1
fi

if ! createMainDrive; then
  echo "Drive creation failed"
  exit 1
fi

if [[ "$INSTALL_OS_FLAG" == "True" ]]; then
  bootInstall
  EXITCODE=$?
else
  bootNoInstall
  EXITCODE=$?
fi

exit $EXITCODE

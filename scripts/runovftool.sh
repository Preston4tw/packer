#!/bin/bash -x

declare -r VM_FILENAME="$1"

if [ -d "/Applications/VMware Fusion.app/Contents/Library" ]; then
  declare -r VMWARE_LIBDIR="/Applications/VMware Fusion.app/Contents/Library"
elif [ -d "/opt/homebrew-cask/Caskroom/vmware-fusion/8.1.0-3272237/VMware Fusion.app/Contents/Library/" ]; then
  declare -r VMWARE_LIBDIR="/opt/homebrew-cask/Caskroom/vmware-fusion/8.1.0-3272237/VMware Fusion.app/Contents/Library/"
else
  echo "Unable to find VMWare" >&2
  exit 1
fi

declare -r VMRUN="${VMWARE_LIBDIR}/vmrun"
declare -r OVFTOOL="${VMWARE_LIBDIR}/VMware OVF Tool/ovftool"

declare -r VMWARE_VMDIR="${HOME}/Documents/VirtualMachines"
declare -r VM_DIR="${VMWARE_VMDIR}/${VM_FILENAME/%ova/vmwarevm}"
declare -r VMXFILE="${VM_DIR}/${VM_FILENAME/%ova/vmx}"

function error() {
  echo "[ERROR] ${@}" >&2
  exit 1
}

function info() {
  echo "[INFO] ${@}"
}

function verify_os() {
  info "Verifying OS is Mac OS X"
  [ "$(uname -s)" == "Darwin" ] || error "Only Mac OS X is supported"
}

function verify_vmware() {
  info "Verifying VMware Fusion 7 or 8 is properly installed"
  [[ -d "${VMWARE_LIBDIR}" ]] || \
    error "VMware Fusion 7 or 8 must be installed"
  [[ -x "${VMRUN}" ]] || \
    error "Cannot locate vmrun, check VMware Fusion installation"
  [[ -x "${OVFTOOL}" ]] || \
    error "Cannot locate ovftool, check VMware Fusion installation"
  mkdir -p "${VMWARE_VMDIR}"
  [[ -d "${VMWARE_VMDIR}" ]] || \
    error "Unable to create directory for VMware VMs: ${VMWARE_VMDIR}"
}


function vmware_import() {

  [[ -f "$1" ]] || error "File $1 not found"

  info "Importing $1"

  mkdir -p "${VM_DIR}"

  [[ -f "${VMXFILE}" ]] && error "A VM appears to already exist at ${VM_DIR}. Delete or rename it if you want to continue."

  "${OVFTOOL}" --lax "$1" "${VMXFILE}"
  perl -pi -e 's/^guestos =.*/guestos = "rhel6-64"/' "${VMXFILE}"

  # Configure Video, CPU, and time settings
  cat >> "${VMXFILE}" << EOF
virtualHW.productCompatibility = "hosted"
mks.enable3d = "TRUE"
svga.graphicsMemoryKB = "786432"
vhv.enable = "TRUE"
vpmc.enable = "TRUE"
tools.syncTime = "TRUE"
svga.minVRAMSize = "67108864"
EOF
  # Start the VM
  info "Starting the VM"
  "${VMRUN}" -T fusion start "${VMXFILE}"
}
vmware_import $1

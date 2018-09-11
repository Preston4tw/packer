#!/bin/bash -x

time PACKER_LOG=1 packer build -on-error=ask -var-file=c6x64/newuser.json c6x64/renametonewuser.json

sleep 5
time PACKER_LOG=1 packer build -on-error=ask -var-file=c6x64/newuser.json c6x64/setupuser.json

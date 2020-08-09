#!/bin/sh
TGTDEV="/dev/sdc"
MOUNT_DIR="/data"


sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
  n
  p
  1


  w
  q
EOF

function format() {
  mkfs.xfs -f ${TGTDEV}1
}

function make_dir() {
  mkdir ${MOUNT_DIR}
}

function mount_set() {
  echo "${TGTDEV}1	${MOUNT_DIR}	xfs	defaults	0 0" >> /etc/fstab
}

format
make_dir
mount_set
mount -a
echo "Done"

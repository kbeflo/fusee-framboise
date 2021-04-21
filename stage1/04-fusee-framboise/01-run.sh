#!/bin/bash -e

on_chroot << EOF
pip3 install pyusb
EOF

rm -rf ${ROOTFS_DIR}/etc/fusee-launcher

mkdir -p ${ROOTFS_DIR}/etc/fusee-launcher

curl -L -o ${ROOTFS_DIR}/etc/fusee-launcher/1.0.zip https://github.com/Qyriad/fusee-launcher/archive/refs/tags/1.0.zip

unzip -j ${ROOTFS_DIR}/etc/fusee-launcher/1.0.zip -d ${ROOTFS_DIR}/etc/fusee-launcher

rm -f ${ROOTFS_DIR}/etc/fusee-launcher/intermezzo.bin

wget -P ${ROOTFS_DIR}/etc/fusee-launcher ${PAYLOAD_LATEST_URL}

if [ ! -f "/etc/fusee-launcher/fusee-primary.bin" ]; then
    unzip ${ROOTFS_DIR}/etc/fusee-launcher/hekate* -d ${ROOTFS_DIR}/etc/fusee-launcher
fi

mv -v ${ROOTFS_DIR}/etc/fusee-launcher/*.bin ${ROOTFS_DIR}/etc/fusee-launcher/fusee.bin

touch $ROOTFS_DIR/etc/systemd/system/fusee-launcher.service

chmod 770 $ROOTFS_DIR/etc/systemd/system/fusee-launcher.service

cat << EOF > $ROOTFS_DIR/etc/systemd/system/fusee-launcher.service
[Unit]
Description = Fusee Launcher service of Fusée Framboise
After = network.target

[Service]
WorkingDirectory=/etc/fusee-launcher/
ExecStart = /etc/fusee-launcher/modchipd.sh

[Install]
WantedBy = multi-user.target
EOF

on_chroot << EOF
systemctl enable fusee-launcher.service
EOF

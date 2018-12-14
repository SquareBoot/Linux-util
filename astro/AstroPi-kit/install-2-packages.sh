#!/bin/bash

echo -e "\n========= Updating apt ========="
sudo apt update

echo -e "\n========= Upgrading system ========="
sudo apt-get -y dist-upgrade

echo -e "\n========= Installing packages ========="
sudo apt install -y astrometry.net python-pip avahi-daemon \
python-pip python-dev libbluetooth-dev bluetooth \
bluez rfkill openssh-client openssh-server tio samba \
cifs-utils git gphoto2 openjdk-9-jdk cdbs libcfitsio-dev libnova-dev \
libusb-1.0-0-dev libjpeg-dev libusb-dev libtiff5-dev libftdi1-dev fxload \
libkrb5-dev libcurl4-gnutls-dev libraw-dev libgphoto2-dev libgsl-dev \
dkms libboost-regex-dev libgps-dev libdc1394-22-dev libftdi1 python-dbus \
python-gobject libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev
sudo dpkg --configure -a

echo -e "\n========= Updating Bluez ========="
cd "$(dirname "$0")/bt-stuff"
./off
sudo apt install -y libbluetooth-dev bluetooth bluez rfkill
sudo sed -i ':a;N;$!ba;s#ExecStart=/usr/lib/bluetooth/bluetoothd\n#ExecStart=/usr/lib/bluetooth/bluetoothd -C\nExecStartPost=/usr/bin/sdptool add SP\n#g' /etc/systemd/system/dbus-org.bluez.service
sudo cp /lib/systemd/system/bluetooth.service /etc/systemd/system/bluetooth.service
sudo sed -i ':a;N;$!ba;s#ExecStart=/usr/lib/bluetooth/bluetoothd\n#ExecStart=/usr/lib/bluetooth/bluetoothd -C\nExecStartPost=/usr/bin/sdptool add SP\n#g' /etc/systemd/system/bluetooth.service
if [[ -z "$(grep "DisablePlugins = pnat" "/etc/bluetooth/main.conf")" ]]; then
  echo "DisablePlugins = pnat" | sudo tee -a "/etc/bluetooth/main.conf"
fi
sudo sed -i 's#AutoEnable=false#AutoEnable=true#g' /etc/bluetooth/main.conf
sudo usermod -aG bluetooth $USER
newgrp bluetooth
sudo rm /dev/rfcomm* 2> /dev/null
sudo cp var-run-sdp.path /etc/systemd/system/var-run-sdp.path
sudo cp var-run-sdp.service /etc/systemd/system/var-run-sdp.service
sudo systemctl daemon-reload
sudo service bluetooth restart
sudo systemctl enable var-run-sdp.path
sudo systemctl enable var-run-sdp.service
sudo systemctl start var-run-sdp.path
./off
sleep 1
./on
sudo sdptool add SP
bluetoothctl -v

echo -e "\n========= Installing Python packages ========="
sudo -H pip install indiweb pybluez wifi sh

read -p "Reboot now? (y/n)?" CONT
if [ "$CONT" = "y" ]; then
    sudo reboot now
fi

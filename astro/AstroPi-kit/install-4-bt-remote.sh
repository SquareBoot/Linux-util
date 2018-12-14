#!/bin/bash
echo -e "\n========= Setting up BT remote control =========\n"
interfaces=()
while read -r line; do
    interfaces+=($line "")
done <<< "$(~/e/net/list-net-devices)"
interface="$(whiptail --title "Astronomy Raspberry Pi" --backtitle "By marcocipriani01" \
--menu "Select a newtwork interface:" 15 50 8 "${interfaces[@]}" 3>&1 1>&2 2>&3)"
if [[ -z "$interface" ]]; then
    interface="null"
fi
pswd="$(whiptail --title "Astronomy Raspberry Pi" --backtitle "By marcocipriani01" \
--inputbox "Enter a password for the hotspot:" 8 70 3>&1 1>&2 2>&3)"
if [[ -z "$pswd" ]]; then
    echo "Error!"
    exit 2
fi
echo "$interface $(hostname) $pswd" > ~/e/astro/hotspot_config
cd "$(dirname "$0")/bt-stuff"
sudo cp hotspot-net-controller.service /lib/systemd/system/hotspot-net-controller.service
sudo systemctl start hotspot-net-controller
sudo systemctl enable hotspot-net-controller


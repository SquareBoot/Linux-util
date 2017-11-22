#!/bin/bash
read -p "Have you ran the setup script (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  sudo apt-get install vdpauinfo
  clear
  vdpauinfo
  echo
  echo "Now you can setup VDPAU using VLC."
  echo "Exit";
  
else
  echo "Exit";
fi

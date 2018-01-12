#!/bin/bash
echo "This script will configure VDPAU for INTEL graphic cards inside your system."
echo "Make sure you are using an Intel card."
read -p "Continue (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  echo "Starting..."
  sudo apt-get -y install libvdpau-va-gl1
  sudo apt-get -y install libva-intel-vaapi-driver
  sudo echo "#!/bin/sh" > /etc/profile.d/vdpau_vaapi.sh
  sudo echo "export VDPAU_DRIVER=va_gl " >> /etc/profile.d/vdpau_vaapi.sh
  sudo chmod +x /etc/profile.d/vdpau_vaapi.sh
  echo "Your system will be rebooted."
  echo "Then, run the following script:"
  echo "libvdpau-config.sh"
  read -p "Continue (y/n)?" CONT
  if [ "$CONT" = "y" ]; then
    sudo reboot
  else
    echo "Please, reboot your system and run the libvdpau-config.sh script"
  fi
  
else
  echo "Cancelled."
fi


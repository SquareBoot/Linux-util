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
  clear
  echo "Your system is going to be rebooted."
  echo "Then, run the following script in a shell:"
  echo "./libvdpau-config.sh"
  echo "Rebooting after confirmation..."
  read -p "Continue (y/n)?" CONT
  if [ "$CONT" = "y" ]; then
    echo "Remember to run the config script!"
    sudo reboot;
  else
    echo "Error: reboot your system";
  fi
  echo "Exit";
  
else
  echo "Exit";
fi


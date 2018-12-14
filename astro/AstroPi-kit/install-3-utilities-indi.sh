#!/bin/bash
echo -e "\n========= Installing INDI ========="
wget --output-document=libindi.tar.gz https://www.indilib.org/download/raspberry-pi/send/6-raspberry-pi/9-indi-library-for-raspberry-pi.html
tar -xzf libindi.tar.gz
cd libindi_1.7.4_rpi
sudo dpkg -i *.deb
cd ..
rm -r libindi_1.7.4_rpi
mv libindi.tar.gz Downloads/libindi.tar.gz

echo -e "\n========= Downloading utilies ========="
git clone https://github.com/marcocipriani01/Linux-util.git
mv Linux-util/ e
git clone https://github.com/marcocipriani01/Linux-util
mv Linux-util/ e
git clone https://github.com/marcocipriani01/shooot.git
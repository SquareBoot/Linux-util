#!bin/bash
echo "Warning: ipython-notebook package isn't available. Consider installing it manually."
sleep 5
echo "Warning: lots of megabytes to download (> 1GB)!"
sleep 5
sudo apt-get install python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose

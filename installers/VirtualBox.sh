#!/bin/bash
clear
echo "Check if the following output isn't empty:"
sleep 3
egrep '(vmx|svm)' /proc/cpuinfo
echo ""
echo "Continue if and only if the given output is not empty."
read -p "Continue (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  sudo apt-get install virtualbox
  sudo apt-get install virtualbox-ext-pack
  echo "Done.";
else
  echo "Exit.";
fi

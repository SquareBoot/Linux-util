#!/bin/bash
read -p "Continue (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  echo "Yep"
  echo "YES";
else
  echo "No"
  echo "NOPE";
fi

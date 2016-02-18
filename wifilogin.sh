#!/bin/bash
#Script attempts to automatically log into my university guest Wifi on Linux devices
#script uses Network Manager's dispatcher.d
#Original version from user chaos on 
#https://askubuntu.com/questions/303519/doing-something-if-connected-to-particular-ssid-in-ubuntu
#data (denoted by <---x--->)for variables below will need to be changed for each user.

# nm sets this values
INTERFACE=$1
ACTION=$2

SSID="<---SSID--->"
ESSID=`iwgetid | cut -d ":" -f 2 | sed 's/"//g'`
#
if [ "$INTERFACE" == "<---Interface--->" ]; then
  if [ "$SSID" == "$ESSID" ] && [ "$ACTION" == "up" ]; then
    curl -d firstname="<---first_name--->" -d lastname="<---last_name--->" -d email="<---email--->" -d FNAME="1" -d button="OK" <---post_url--->
  else
    echo "Not guest wifi!"
  fi
fi

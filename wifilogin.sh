#!/bin/bash
#Script attempts to automatically log into the Schriener Wifi on Linux devices
#Original version from user chaos on 
#https://askubuntu.com/questions/303519/doing-something-if-connected-to-particular-ssid-in-ubuntu

#Pull the current user that is still logged in.  Not sure how to handle concurrent logins,
#but on a laptop with one user at a time this shouldn't be a problem.
last_user=`last | grep "still logged" | head -n 1 | cut -d " " -f 1`

#Get the login details from the user's home directory.
source /home/$last_user/wifi_login_details.sh

# Network Manager sets these values
INTERFACE=$1
ACTION=$2

#Begin checks for the SSID from the config file in the home directory.
SSID=$ssid
ESSID=`iwgetid | cut -d ":" -f 2 | sed 's/"//g'`
#
if [ "$INTERFACE" == `iwgetid | cut -d " " -f 1` ]; then
  if [ "$SSID" == "$ESSID" ] && [ "$ACTION" == "up" ]; then
    curl -d firstname="$firstname" -d lastname="$lastname" -d email="$email" -d FNAME="1" -d button="OK" $post_url
    exit 0
  else
    echo "Not University Wifi!"
    exit 0
  fi
fi

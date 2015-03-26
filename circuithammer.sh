#!/bin/bash
#Script is called with [scriptname] [interface] [filetoget].
#To do: timeout wget processes if left running and handle improper arguments.

#Arguments we use.
interface=$1
fileToGet=$2

#Handle if no interface specified.
if [ $# -eq 0 ]
	then
		interface="eth0"
		echo
		echo "No interface specified so using eth0."
		echo "Specify an interface with [script] [interface]."
		echo
fi

if [ -z "$1" ]
	then
		interface="eth0"
fi

#Handle no file given.
if [ -z "$2" ]
	then
		echo
		echo "No file given. Specify with [script] [interface] [file]."
		echo
		exit 1
fi

#Grab the IP of the interface specified since wget doesn't take interface names.
address=`ifconfig $interface | grep "inet addr" | cut -d: -f2 | awk '{ print $1}'`

#General info for user.
echo
echo "Using $interface with $address."
echo
echo "DO NOT FORGET TO killall wget."
echo

#Time to hammer that circuit.
for rev in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
	do
		wget $fileToGet -o /dev/null --output-document=/dev/null --background --bind-address=$address
done

#!/bin/bash

# this script checks if the file /var/run/reboot-required is present
# should work on all debian-based systems...

if [ -f "/var/run/reboot-required" ]
then
    echo "reboot required!"
    exit 1
else
    echo "looks good over here..."
    exit 0
fi



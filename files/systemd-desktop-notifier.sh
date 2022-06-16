#!/bin/bash

# Copyright (c) 2020 Adrian Wyssmann

# Adrian Wyssmann can be found at https://github.com/papanito

# Send notifications to desktop using notify-send (libnotify)
SERVICE=
USERID=1000

# Function: Print a help message.
usage() {
  echo "Usage: $0 -s servicename -u username -f" 1>&2
}

# Function: Exit with error.
exit_abnormal() {
  usage
  exit 1
}

if [ "$#" -lt "2" ]; then
   exit_abnormal
fi

while getopts ":s:u:f" option; do
   case ${option} in
      s )
         SERVICE=$OPTARG
         ;;
      f )
         FULLSTATUS=true
         ;;
      u )
         USERID=$(id -u $OPTARG)
         ;;
      \? )
         exit_abnormal
      ;;
      *)
         exit_abnormal
      ;;
    esac
done
if [ -v FULLSTATUS ]; then
   status=$(systemctl status --full $SERVICE)
else
   status=$(systemctl status $SERVICE | grep -E 'Active:\sfailed')
fi
status=$(sed 's/Active://' <<< "$status")

if [[ -n "$status" ]]; then
   DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USERID/bus notify-send --app-name=$SERVICE $SERVICE "$status"
fi

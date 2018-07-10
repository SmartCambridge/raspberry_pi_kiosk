#!/bin/bash
#
# SmartPanel kiosk-mode startup script

echo "-----------------------------------" >>/home/pi/run.log

echo >>/home/pi/run.log

echo "$(date) SmartPanel run.sh  starting" >>/home/pi/run.log

echo "$(date) running settime..." >>/home/pi/run.log

/home/pi/ijl20_toolz/settime.sh >>/home/pi/run.log 2>>/home/pi/settime.err

echo "$(date) running chromium-browser..." >>/home/pi/run.log

chromium-browser --noerrdialogs --incognito --kiosk https://smartcambridge.org/smartpanel/display/MAKY-5714 &

echo "$(date) run.sh completed" >>/home/pi/run.log

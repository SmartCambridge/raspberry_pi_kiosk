#!/bin/bash
#
# SmartPanel kiosk-mode startup script

echo "-----------------------------------" >>/home/ijl20/run.log

echo >>/home/ijl20/run.log

echo "$(date) SmartPanel run.sh  starting" >>/home/ijl20/run.log

echo "$(date) running settime..." >>/home/ijl20/run.log

/home/ijl20/settime.sh >>/home/ijl20/run.log 2>>/home/ijl20/settime.err

echo "$(date) running chromium-browser..." >>/home/ijl20/run.log

firefox --noerrdialogs -kiosk -private-window https://smartcambridge.org/smartpanel/display/MAKY-5714 >/home/ijl20/firefox.log 2>/home/ijl20/firefox.err&

echo "$(date) run.sh completed" >>/home/ijl20/run.log

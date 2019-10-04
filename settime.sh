#!/bin/bash
#
# GETS A WEB PAGE, PICKS OUT THE TIMESTAMP FROM THE RESPONSE HEADER, SETS SYSTEM CLOCK

TIMEURL="http://smartcambridge.org/backdoor/time.png"
#TIMEURL="http://tfc-app2.cl.cam.ac.uk/backdoor/time.png"

while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "settime.sh from ijl20_toolz"
            echo "Sets the system clock after reading time from smartcambridge.org"
            echo "Run as root if you want to change the system time"
            echo "Usage:"
            echo "  options:"
            echo "    -t, --test: retrieve time but do not set system clock"
            echo "    -h, --help: display this help information"
            exit 0
            ;;

        -t|--test)
            echo "Test mode: getting time from $TIMEURL..."
            TEST=t
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Query the time from SmartCambridge.org and set the local system clock accordingly

# We'll time the GET in nanoseconds, ignoring overhead of other code...
TIMEGET=$(date +%s%N)

LOOPCOUNT=0
LOOPEXIT="f"
SLEEPTIME=20

while ((LOOPCOUNT < 30))  && [[ $LOOPEXIT == "f" ]]; do
    # get the headers from the website, including 'date:'
    CURLRETURN=$(curl --head -s $TIMEURL)
    # capture the curl command exit value, 0 means GET OK, 6 or 7 means no network
    CURLEXIT=$?
    # we will exit the loop if curl returns anything other than 6 or 7 for no network
    if (( CURLEXIT != 6 && CURLEXIT != 7 )); then
        LOOPEXIT="t"
    fi
    # echo "curl exit $CURLEXIT so LOOPEXIT is $LOOPEXIT"
    if [[ $LOOPEXIT == "f" ]]; then
        LOOPCOUNT=$((LOOPCOUNT + 1))
        if (( LOOPCOUNT == 10 )) || (( LOOPCOUNT == 20 )); then
            SLEEPTIME=$(( SLEEPTIME * 10 ))
        fi
        echo "$(date) Attempt $LOOPCOUNT. Curl failed to get time, sleeping $SLEEPTIME seconds and retrying..."
        sleep $SLEEPTIME
    fi
done

# Anything other than a zero exit value from curl and we quit here
if (( CURLEXIT != 0 )); then
    echo "$(date) settime.sh Failed to get time, aborting"
    exit
fi

# echo CURLRETURN is "$CURLRETURN"

NOW=$(echo "$CURLRETURN" | grep -Fi date | awk '{$1=""; print}')

TIMEGOT=$(date +%s%N)

NETTIME=$(( (TIMEGOT - TIMEGET) / 1000000 ))

if [[ "$TEST" == "t" ]]; then
    echo "$(date) NOW = $NOW"
    echo "$(date) Retrieved in $NETTIME ms"
    exit 0
else
    echo "$(date) Setting date..."
    sudo date -s "$NOW"
fi



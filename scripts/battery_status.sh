#!/bin/env bash
#Get battery status
cd /sys/class/power_supply
for f in `ls`; do
if [ -e $f"/capacity" ]; then
export stat=`cat $f"/status"`
export cap=`cat $f"/capacity"`
echo battery $f": "$stat", "$cap"%"
fi
done|zenity --text-info --filename=/dev/stdin --title "Power Status"
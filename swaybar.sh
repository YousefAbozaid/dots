#!/bin/bash

# إعدادات تنسيق التاريخ (12 ساعة + اسم اليوم)
date_format="%A, %Y/%m/%d %I:%M %p"
show_week=true

# الوقت والتاريخ
datetime=$(date +"$date_format")
week=""
$show_week && week=" Week $(date +%V) │ "

# البطارية
if [ -f /sys/class/power_supply/BAT0/capacity ]; then
  percent=$(cat /sys/class/power_supply/BAT0/capacity)
  status=$(cat /sys/class/power_supply/BAT0/status)
  battery="🔋 $percent % ($status)"
else
  battery="🔋 N/A"
fi

# طباعة السطر النهائي
echo "$week $datetime │ $battery"

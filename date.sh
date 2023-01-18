#!/bin/bash
REGEX="^([0-9]+h)?([0-9]+m)?([0-9]+s)?$"
MAX_TIME="15m"

function calc_total_sec() {
  TIME=$1
  hour=`echo $TIME | sed -r "s/$REGEX/\1/" | sed -r 's/^([0-9]+)h$/\1/'`
  min=`echo $TIME | sed -r "s/$REGEX/\2/" | sed -r 's/^([0-9]+)m$/\1/'`
  sec=`echo $TIME | sed -r "s/$REGEX/\3/" | sed -r 's/^([0-9]+)s$/\1/'`

  # echo "min is $min"
  # echo "sec is $sec"

  total_sec=0

  if [ -n "$hour" ] && [ $hour -ge 0 ]; then
  # echo "hour=$hour is larger than 0."
    total_sec=$(expr 60 \* 60 \* $hour)
  fi


  if [ -n "$min" ] && [ $min -ge 0 ]; then
  # echo "min=$min is larger than 0."
    total_sec=$(expr $total_sec + 60 \*  $min)
  fi

  if [ -n "$sec" ] && [ $sec -ge 0 ]; then
  # echo "sec=$sec is larger than 0."
    total_sec=$(expr $total_sec + $sec);
  fi

  echo $total_sec
}

# if [[ ! $1 =~ $REGEX ]]; then
#   echo "マッチしません"
#   exit
# fi

if [ -n "$1" ] && [[ $1 =~ $REGEX ]]; then
  result=$(calc_total_sec $1)
  default=$(calc_total_sec $MAX_TIME)

  echo $result
  echo $default

  if [ $result -gt $default ]; then
    echo "上限値を超えました"
  fi

fi

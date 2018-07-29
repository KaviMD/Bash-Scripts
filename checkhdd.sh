#!/bin/sh

HDDLOC="/dev/"
mapfile -t HDDLIST < <(geom disk list | grep name | cut -d ' ' -f 3)

SENDMSG=false
email="kaviasher@gmail.com"

declare -i numalerts=0
alerts=""
declare -i numwarnings=0
warnings=""

echo $numwarnings

for i in "${HDDLIST[@]}"
do
        HDD="$HDDLOC$i"
        echo "$i"
        #echo "$HDD"
        HDDTEMP="$(smartctl -A "$HDD" | grep '^194' | cut -d ' ' -f 37)" 
        echo "$HDDTEMP"
        if [ $HDDTEMP -gt 49 ] && [ $HDDTEMP -lt 55 ]
        then
                warn="Warning Hard Drive $HDDLOC$i is getting to hot. It is $HDDTEMP C"
                #echo $warn
                numwarnings=$(($numwarnings + 1))
                warnings="$warnings \n$warn"
                SENDMSG=true
        elif [ $HDDTEMP -gt 54 ] 
        then
                alert="ALERT HARD DRIVE $HDDLOC$i IS OVER HEATING. IT IS $HDDTEMP C"
                #echo $alert
                numalerts=$(($numalerts + 1))
                alerts="$alerts \n$alert"
                SENDMSG=true
        fi
done

#echo $numwarnings
#echo $warnings
#echo $numalerts
#echo $alerts

msg=""
subject="Hard Drive Issues:"

if [ $numwarnings -gt 0 ]
then
        if [ $numalerts -gt 0 ]
        then
                msg="There is $numwarnings warning(s) and"
                subject="$subject $numwarnings warning(s) and"
        else
                msg="There is $numwarnings warning(s)."
                subject="$subject $numwarnings warning(s)"
        fi
fi

if [ $numalerts -gt 0 ]
then
        if [ $numwarnings -gt 0 ]
        then 
                msg="$msg $numalerts alert(s)."
                subject="$subject $numalerts alert(s)"
        else
                msg="There is $numalerts alert(s)."
                subject="$subject $numalerts alert(s)"
        fi
fi

msg="${msg}\n\n${warnings}\n\n${alerts}"
if $SENDMSG
then
        echo -e $msg
        echo $subject
        mail -s "$subject" $email <<< "$(echo -e $msg)"
fi
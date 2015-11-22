#!/bin/bash

echo "Creazione Lista di Anni Mesi e Giorni"

YEAR=1970

DATE_BEFORE=0
DATE_AFTER=0
CHECK_TURN="1"

while [ "$YEAR" -le "2037"  ];do

                for (( MONTH=1;MONTH<=12;MONTH++ )); do

                        DAYS=30;

                        if [ "$MONTH" -ne "4" ] && [ "$MONTH" -ne "6"  ] && [ "$MONTH" -ne "9"  ] && [ "$MONTH" -ne "11"  ]; then
                                DAYS=$(( $DAYS+ 1 ));
                        fi

                        if [ "$MONTH" -eq "2" ]; then
                                if [ $(( $YEAR % 4 )) -eq 0 ] &&  [ $(( $YEAR % 100 )) -ne 0 ] || [ $(( $YEAR % 400 )) -eq 0 ] ;then
                                        DAYS=29
                                else
                                        DAYS=28
                                fi
                        fi
                        for (( i=1;i<=$DAYS;i++ )); do
				
				
				if [ "$CHECK_TURN" == "0" ]; then
					
					echo "$YEAR-$(printf %02d $MONTH)-$(printf %02d $i)" >> date.log
					DATE_SW_AFTER="$YEAR$(printf %02d $MONTH)$(printf %02d $i)"
					echo -n "sleep for 3 seconds and then recheck the hardware"
					for a in `seq 1 3`
					do
						echo -n " ."
						sleep 1
					done
					echo				
					DATE_HW_AFTER=`hwclock -r -D | grep  "Hw clock time" | awk '{print $5}' | tr -d '/'`
					if [ "$DATE_SW_AFTER" -eq "$DATE_HW_AFTER"  ];then
						echo
						echo "ok, Data HW : $DATE_HW_AFTER corrisponde alla Data SW : $DATE_SW_AFTER"
						echo
					else
						echo
						echo "#!KO!, Data HW : $DATE_HW_AFTER NON corrisponde alla Data SW : $DATE_SW_AFTER" >> error.log
						echo "ERROR DATE HW: $DATE_HW_AFTER <> SW: $DATE_SW_AFTER"
						echo
					fi
					CHECK_TURN="1"
				else
					DATE_BEFORE="$YEAR$(printf %02d $MONTH)$(printf %02d $i)"
					echo "Setting Date to $DATE_BEFORE and then check it"
                                	date $(printf %02d $MONTH)$(printf %02d $i)2359$YEAR.59
                                	hwclock -w	


					CHECK_TURN="0"
				fi
								
                        done

                done
        YEAR=$(( $YEAR+ 1  ))
done

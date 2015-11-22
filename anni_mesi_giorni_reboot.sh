#!/bin/bash


YEAR=`cat /opt/SAVE/anni`
MESI=`cat /opt/SAVE/mesi`
GIORNI=`cat /opt/SAVE/giorni`
CHECK_TURN=`cat /opt/SAVE/turn`

DATE_BEFORE=0
DATE_AFTER=0
#CHECK_TURN="1"


MONTH=$MESI

echo -n "sleep for 1 seconds and check"
for a in `seq 1 1`
do
	echo -n " ."
	sleep 1
done

while [ 1 ]; do

if [ "$YEAR" -le "2037"  ]; then
		
		
		if [ $MONTH -le 12 ]; then
		
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
			
			if [ $GIORNI -le $DAYS  ]; then

				if [ "$CHECK_TURN" == "0" ]; then

                                        echo "$YEAR-$(printf %02d $MONTH)-$(printf %02d $GIORNI)" >> date.log
                                        DATE_SW_AFTER="$YEAR$(printf %02d $MONTH)$(printf %02d $GIORNI)"

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
                                        
					GIORNI=$(( $GIORNI+ 1))
                                	echo "$GIORNI" > /opt/SAVE/giorni
					CHECK_TURN="1"
                                        echo "1" > /opt/SAVE/turn
					echo "logout. . . 1"
					continue

                                else
                                        DATE_BEFORE="$YEAR$(printf %02d $MONTH)$(printf %02d $GIORNI)"
                                        echo "Setting Date to $DATE_BEFORE and then check it"
                                        date $(printf %02d $MONTH)$(printf %02d $GIORNI)2359$YEAR.59
                                        hwclock -w
					
					GIORNI=$(( $GIORNI+ 1))
                                        echo "$GIORNI" > /opt/SAVE/giorni
                                        CHECK_TURN="0"
                                        echo "0" > /opt/SAVE/turn
                                	echo "reboooooooooooooot. . . 1"
					reboot
					
				fi	

			else
				echo "NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"	
				GIORNI=1
				echo "$GIORNI" > /opt/SAVE/giorni
				MONTH=$(( $MONTH+ 1))
				echo "$MONTH" > /opt/SAVE/mesi
				echo "logout. . . 2"
				continue
	
			fi

			

			
		
			#echo "$(( $MESI+ 1 ))" > /opt/SAVE/mesi


		else

			YEAR=$(( $YEAR+ 1))
			echo "$YEAR" > /opt/SAVE/anni
			MONTH=1;
			echo "$MONTH" > /opt/SAVE/mesi

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
		
			if [ $GIORNI -le $DAYS  ]; then

                                if [ "$CHECK_TURN" == "0" ]; then

                                        echo "$YEAR-$(printf %02d $MONTH)-$(printf %02d $GIORNI)" >> date.log
                                        DATE_SW_AFTER="$YEAR$(printf %02d $MONTH)$(printf %02d $GIORNI)"

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

                                        GIORNI=$(( $GIORNI+ 1))
                                        echo "$GIORNI" > /opt/SAVE/giorni
                                        CHECK_TURN="1"
                                        echo "1" > /opt/SAVE/turn
                                        echo "logout. . . 3"
                                        continue

                                else
                                        DATE_BEFORE="$YEAR$(printf %02d $MONTH)$(printf %02d $GIORNI)"
                                        echo "Setting Date to $DATE_BEFORE and then check it"
                                        date $(printf %02d $MONTH)$(printf %02d $GIORNI)2359$YEAR.59
                                        hwclock -w

                                        GIORNI=$(( $GIORNI+ 1))
                                        echo "$GIORNI" > /opt/SAVE/giorni
                                        CHECK_TURN="0"
                                        echo "0" > /opt/SAVE/turn
                                        echo "reboooooooooooooot. . . 2"
                                        reboot

                                fi

                        else

                                GIORNI=1
                                echo "$GIORNI" > /opt/SAVE/giorni
                                MONTH=$(( $MONTH+ 1))
                                echo "$MONTH" > /opt/SAVE/mesi
                                echo "logout. . . 4"
                                continue

                        fi
	

		
		
			
			
		fi

else
		
	echo "Fine TEST!"
	poweroff		

fi

done





#!/bin/bash


LS="/var/lib/asterisk/agi-bin/DialerCamps"
TIME="15"  #Seconds


echo "Iniciando Servicio de Dialerd ................................ $(date)"
rm -rf /var/run/apache2
rm -rf /var/run/asterisk
sleep $TIME



while true;do 

	echo "Revisando mensajes pendientes ............................... $(date)"
	for i in $(ls $LS);do 

		if [ -d "$LS/$i" ] && [ "$i" != "Test" ] ;then 
		
			echo -n "Revisando mensajes en $i ..............................."
			if [ -f "/var/lib/asterisk/agi-bin/DialerCamps/$i/cron_$i.php" ];then
				cd /var/lib/asterisk/agi-bin/DialerCamps/$i
				/usr/bin/php /var/lib/asterisk/agi-bin/DialerCamps/$i/cron_$i.php
			fi
			echo "Ok"
	
		fi


	done
	sleep $TIME
done

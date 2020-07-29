FROM nsoporte/asterisk:11.25.3

RUN  apt-get update; apt-get -y upgrade; \
	apt-get -y install apache2 php5 php5-mysql mysql-client supervisor; \
	rm -rfv /var/www/html; \
	rm -rfv /var/lib/asterisk; \
	rm -rf /etc/supervisor/conf.d


COPY	files/html /var/www/html
COPY	files/conf.d /etc/supervisor/conf.d
COPY    files/envvars /etc/apache2
COPY    files/etc-asterisk /opt/asterisk/etc/asterisk
COPY    files/var-asterisk  /opt/asterisk/var/lib/asterisk
COPY    files/spool-asterisk /opt/asterisk/var/spool/asterisk
COPY	files/dialerdb.sql /opt


RUN	chown -R asterisk.asterisk /var/www/html; \
	chown -R asterisk.asterisk /var/lib/asterisk/agi-bin; \
	chown -R asterisk.asterisk /var/log/apache2; \
	chown -R asterisk.asterisk /etc/apache2; \
	chown -R asterisk.asterisk /opt/asterisk/etc/asterisk/; \
	chown -R asterisk.asterisk /opt/asterisk/var/lib/asterisk/; \
	chown -R asterisk.asterisk /opt/asterisk/var/spool/asterisk/; \
	chown -R asterisk.asterisk /etc/asterisk; \
	chown -R asterisk.asterisk /var/lib/asterisk/; \
	chown -R asterisk.asterisk /var/spool/asterisk/; \
	chmod +x /var/lib/asterisk/agi-bin/*


RUN	rm /opt/asterisk/lib/asterisk/modules/pbx_lua.so; \ 
  	rm /opt/asterisk/lib/asterisk/modules/pbx_ael.so; \ 
  	rm /opt/asterisk/lib/asterisk/modules/cel_tds.so; \
   	rm /opt/asterisk/lib/asterisk/modules/cdr_pgsql.so; \ 
   	rm /opt/asterisk/lib/asterisk/modules/res_config_pgsql.so; \ 
   	rm /opt/asterisk/lib/asterisk/modules/chan_motif.so; \ 
   	rm /opt/asterisk/lib/asterisk/modules/chan_mobile.so 





CMD [ "supervisord", "-n" , "-c", "/etc/supervisor/supervisord.conf" ]

ENTRYPOINT []

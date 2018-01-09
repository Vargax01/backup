#!/bin/bash
#Este script hara copias de seguridad diferenciales cada día.
function copia()
{
	date=`date +%d-%m-%Y`
	hostname=`ssh root@$1 hostname -s`
	ssh root@$1 mkdir /tmp/backups/
	#Diferencial del etc
	ssh root@$1 "rm /etc/etc.snar"
	ssh root@$1 "cp /etc/etc-comp.snar /etc/etc.snar"
	ssh root@$1 "tar --warning=no-file-changed -czpf /tmp/backups/etc_backup_dif.tar.gz -g /etc/etc.snar /etc/*"
	#Diferencial del home
	ssh root@$1 "rm /home/.home.snar"
	ssh root@$1 "cp /home/.home-comp.snar /etc/.home.snar"
	cont=`ssh root@$1 ls /home/ | wc -l`
	while [ $cont -ne 0 ];
	do
	ssh root@$1 "tar --warning=no-file-changed -czpf /tmp/backups/home_`ssh root@$1 ls /home/ | head -$cont | tail -1`_backup_dif.tar.gz -g /home/.home.snar /home/`ssh root@$1 ls /home/ | head -$cont | tail -1`/importante /home/`ssh root@$1 ls /home/ | head -$cont | tail -1`/.ssh"
		cont=$(($cont-1))
	done
	#Creamos archivo para guardar programas instalados
	if [ $hostname == "donald" ];
	then
		ssh root@$1 "rpm -qa > /root/programas.txt"
	else
		ssh root@$1 'dpkg -l | cut -d" " -f3 > /root/programas.txt'
	fi
	#Copia diferencial del home de root
	ssh root@$1 "rm /root/root.snar"
	ssh root@$1 "cp /root/root-comp.snar /root/root.snar"
	ssh root@$1 "tar --warning=no-file-changed -czpf /tmp/backups/root_backup_dif.tar.gz -g /root/root.snar /root/* /root/.pgpass /root/.ssh"
	#Copia diferencial del /var/lib, /var/www, /var/cache
	ssh root@$1 "rm /var/var.snar"
	ssh root@$1 "cp /var/var-comp.snar /var/var.snar"
	ssh root@$1 "tar --warning=no-file-changed -czpf /tmp/backups/var_lib_backup_dif.tar.gz -g /var/var.snar /var/lib/* /var/www/* /var/cache/*"
	ssh root@$1 "tar -czpf /tmp/backups/dif_Backup_$date.tar.gz /tmp/backups/*"
	scp root@$1:/tmp/backups/dif_Backup_$date.tar.gz /backups/$hostname/
	ssh root@$1 rm -r /tmp/backups
	if [ -f /backups/$hostname/dif_Backup_$date.tar.gz ];
	then
		estado=200
		echo "Se ha realizado correctamente la copia de seguridad diferencial de $hostname" | sendmail miguelchico14@gmail.com
	else
		estado=400
		echo "Se ha producido un error al realizar la copia de seguridad diferencial de $hostname" | sendmail miguelchico14@gmail.com
	fi
	psql -h 172.22.200.110 -U miguel.vargas -d db_backup -c "INSERT INTO BACKUPS (backup_user, backup_host, backup_label, backup_description, backup_status, backup_mode) values ('miguel.vargas', '$1','dif_Backup_$date_$hostname.tar.gz','Copia diferencial de $hostname el $date', '$estado', 'Automatica')"
}
#          		.d88888888bo.
#                      .d8888888888888b.
#                      8888888888888888b
#                      888888888888888888
#                      888888888888888888
#                       Y8888888888888888
#                 ,od888888888888888888P
#              .'`Y8P'```'Y8888888888P'
#            .'_   `  _     'Y88888888b
#           /  _`    _ `      Y88888888b   ____
#        _  | /  \  /  \      8888888888.d888888b.
#       d8b | | /|  | /|      8888888888d8888888888b
#      8888_\ \_|/  \_|/      d888888888888888888888b
#      .Y8P  `'-.            d88888888888888888888888
#     /          `          `      `Y8888888888888888
#     |                        __    888888888888888P
#      \                       / `   dPY8888888888P'
#       '._                  .'     .'  `Y888888P`
#          `"'-.,__    ___.-'    .-'
#         jgs  `-._````  __..--
###################################################
#		Mickey				  #
###################################################
copia 172.22.200.104
#Minnie Mouse              c<> ,
#                         ,CCC cC>       ...:  ...
#                        ,CCCC'CC>   .::::`.ccCCCCC
#                        CCCCCcCC'  :::'.cCCCCCCCCC
#                        CCCCCC-'  `:'.CcCC`CCCCCC ::
#                      ,C`CCC',cCCCc ` <CCCC,CCCC'::::
#                     ,CCCCC',CCCCC',cCCCCCCCCCC'.:::
#                     `CCCC' CCCCC cCCCCCCCCCC',C :'
#                      C>''.:  .,.  `CCCCCCCCCcCC        ...
#                     ,cd ,ud$$$$$$$c `CCCCCCCCCC    :::::::::::.
#                  ,c$$$,J$$$$$$$$$$$b `CCCCCCC'   .::::::::::::::
#                ,d$$$$$$?$$$$$$$$$$$$L:..`''' :   ::::::::::::::::
#            .\.\`-,$$"$,?"=$$$$$$$$$$E :::`CCC : .:::::::::::::::::
#             `/ ,,"?$h` =?$,?$$$$$$$$F ::::`CCC :::::::::::::::::::
#      .      J.$$$:$$'d$h,"$ $$$$$$$$'::::::`CC,`:::::::::::::::::
#    :::.`.   F`""?;$'d$$$$h J$$$$$$$P :::::::<CC : `:::::::::::::
#    ::::::   h    $$ ""?$$F,$$$$$$$P.'`,,``:: CC :  ``:::::::::'
#    `:::::: cc,. d$$    `",$$$$$$$6,c$$$$$$c <CC         ```
#      `:::'J$$$$$c`?=.,,c$$$$$$$$$$$$$$$$$$$h `C
#       hcc$$$$$$$$$i?h$$$$$$$$$$??(("?$$$$$$$>,'
#       `$$$$$$$$$$$$$$$$$$$$$$$$$$P,$c$$$$$$$
#        `$$$$$$$$$$$$$$$$$$$$$$$$",$$$$$$$$F
#          `?$$$$$$$$$$$$$$$$$FF",J$$$$$$$F
#             `"??$$$$$$$???",;d??$$$F".:.
#                    : =cddd??" `" . :::::::
#                 .:`.:::: :::::'.:::::::::::
############################################
#		Minnie			   #
############################################
copia 172.22.200.95
#                                       .;;;..
#                                    ;<!!!!!!!!;
#                                 .;!!!!!!!!!!!!>
#                               .<!!!!!!!!!!!!!!!
#                              ;!!!!!!!!!!!!!!!!'
#                            ;!!!!!!!!!!!!!!!!!'
#                           ;!!!!!!!!!!!!!!!''
#                         ,!!!!!!!!!!!!!'` .::
#                  ,;!',;!!!!!!!!!!!'` .::::''  .,,,,.
#                 !!!!!!!!!!!!!!!'`.::::' .,ndMMMMMMM,
#                !!!!!!!!!!!!!' .::'' .,nMMP""',nn,`"MMbmnmn,.
#                `!!!!!!!!!!` :'' ,unMMMM" xdMMMMMMMx`MMn
#             _/  `'!!!!''`  ',udMMMMMM" nMMMMM??MMMM )MMMnur=
#,.... ......--~   ,       ,nMMMMMMMMMMnMMP".,ccc, "M MMMMP' ,,
# `--......--   _.'        " MMP??4MMMMMP ,c$$$$$$$ ).MMMMnmMMM
#     _.-' _..-~            =".,nmnMMMM .d$$$$$$$$$L MMMMMMMMMP
# .--~_.--~                  '.`"4MMMM  $$$$$$$$$$$',MMMMMPPMM
#`~~~~                      ,$$$h.`MM   `?$$$$$$$$P dMMMP , P
#                           <$""?$ `"     $$$$$$$$',MMMP c$
#                           `$c c$h       $$$$$$$',MMMM  $$
#                            $$ $$$       $$$$$$',MMMMM  `?
#                            `$.`$$$c.   z$???"  "',,`"
#                             3h $$$$$cccccccccc$$$$$$$$$$$=r
#                             `$c`$$$$$$$$$$$$$$$??$$$$F"$$ "
#                           ,mr`$c`$$$$$$$$$$$$$$c 3$$$$c$$
#                        ,mMMMM."$.`?$$$$$$$$$$$$$$$$$$$$$$h,
#;.   .               .uMMMMMMMM "$c,`"$$$$$$$$$$$$$$$$C,,,,cccccc,,..
#!!;,;!!!!> .,,...  ,nMMMMMMMMMMM.`?$c  `"?$$$$$$$$$$$$$$$$$$$$$$$$$$$$h.
#!!!!!!!!! uMM" <!!',dMMMMMMMMMMPP" ?$h.`::..`""???????""'..  -==cc,"?$$P
#!!!!!!!!'.MMP <!',nMMMMMMMMP" .;    `$$c,`'::::::::::::'.$F
#!!!!!!!! JMP ;! JMMMMMMMP" .;!!'      "?$hc,.````````'.,$$
#!!!!'''' 4M(;',dMMMP""" ,!!!!` ;;!!;.   "?$$$$$?????????"
#!!! ::. 4b ,MM" .::: !''`` <!!!!!!!!;
# `!::::.`' 4M':::::'',mdP <!!!!!!!!!!!;
#! :::::: ..  :::::: ""'' <!!!!!!!!!!!!!!;
#!! ::::::.::: .::::: ;!!> <!!!!!!!!!!!!!!!!!;.
#!! :::::: `:'::::::!!' <!!!!!!!!!!!!!!!!!!!!!;;.
#! ::::::' .::::' ;!' .!!!!!!!!!!!!!!'`!!!!!!!!!!!;.
#; `::';!>  ::' ;<!.;!!!!!!!''''!!!!' <!! !!!!!!!!!!!>
#######################################################
#			Donald			      #
#######################################################
copia 172.22.200.96

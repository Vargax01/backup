#!/bin/bash
echo "#######################"
echo "#Mickey 172.22.200.104#"
echo "#Minnie 172.22.200.95 #"
echo "#Donald 172.22.200.96 #"
echo "#######################"
echo "Introduzca ip de máquina a restaurar: "
read ip
echo "Introduzca fecha de la completa(dd-mm-yyyy): "
read full
echo "Introduzca fecha de la incremental(dd-mm-yyyy): "
read inc

hostname=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip hostname -s`
scp /backups/$hostname/Full_Backup_$full.tar.gz root@$ip:/tmp/
scp /backups/$hostname/inc_Backup_$inc.tar.gz root@$ip:/tmp/
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip "tar -xzpf /tmp/Full_Backup_$full.tar.gz -C /"
cont=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip ls /tmp/backups/ | wc -l`
while [ $cont -ne 0 ];
do
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip "tar -xzpf /tmp/backups/`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip ls /tmp/backups/ | head -$cont | tail -1` -C /"
	cont=$(($cont-1))
done
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip rm -r /tmp/backups
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip "tar -xzpf /tmp/inc_Backup_$inc.tar.gz -C /"
cont=`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip ls /tmp/backups/ | wc -l`
while [ $cont -ne 0 ];
do
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip "tar -xzpf /tmp/backups/`ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip ls /tmp/backups/ | head -$cont | tail -1` -C /"
        cont=$(($cont-1))
done
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip rm -r /tmp/backups
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip rm /tmp/Full_Backup_$full.tar.gz
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ip rm /tmp/inc_Backup_$inc.tar.gz

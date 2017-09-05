#!/bin/bash
output="/tmp/accountusage"
domain="xyz.com"
email=receiver@xyz.com
rm -rf $output
touch $output

server=`zmhostname`
/opt/zimbra/bin/zmprov gqu $server|grep $domain|awk {'print $1" "$3" "$2'}|sort|while read line
do
usage=`echo $line|cut -f2 -d " "`
quota=`echo $line|cut -f3 -d " "`
user=`echo $line|cut -f1 -d " "`

status=`/opt/zimbra/bin/zmprov ga $user | grep  ^zimbraAccountStatus | cut -f2 -d " "`
echo "$user `expr $usage / 1024 / 1024`Mb `expr $quota / 1024 / 1024`Mb ($status account)" >> $output
done
Total=`sed 's/Mb//g' $output|awk '{sum += $2} END {print sum/1024}'`
echo "Total size in GB $domain= $Total GB" >>$output
/opt/zimbra/postfix/sbin/sendmail -t "Disk-Space" "$email"<$output
~                                                                                

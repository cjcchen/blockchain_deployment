
cmd=$1
. ipconfig.sh
set -x

count=0
i=0
for ip in ${iplist[@]}
do
	`$cmd` &
	((count++))
done


while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done



. ipconfig.sh

set -x

count=0
i=0
for ip in ${iplist[@]}
do
	ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "killall -9 geth" &
	((count++))
done



while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done

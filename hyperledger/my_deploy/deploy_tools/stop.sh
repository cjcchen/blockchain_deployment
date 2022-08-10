set -x

. config/ip_config.sh

count=0
for ip in ${list[@]}
do
ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "sh /home/ubuntu/hyperledger/script/clear.sh &" &
((count++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done

count=0
for ip in ${order_list[@]}
do
ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "sh /home/ubuntu/hyperledger/script/clear.sh &" &
((count++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done

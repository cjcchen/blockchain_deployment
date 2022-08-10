
set -x

. config/ip_config.sh

./deploy_tools/stop.sh

count=0
for ip in ${order_list[@]}
do
ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "cd /home/ubuntu/hyperledger/orderer/; ulimit -n 512000; nohup sh start_order.sh > orderer.log 2>&1 &" &
((count++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done

count=0
for ip in ${list[@]}
do
ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "cd /home/ubuntu/hyperledger/peer/; ulimit -n 512000; nohup sh start_peer.sh  > peer.log 2>&1 &" &
((count++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done

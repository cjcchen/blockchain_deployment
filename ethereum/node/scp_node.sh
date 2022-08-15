
ps -ef | grep -i test2 | awk '{ print "kill -9 "$2 }' | sh

set -x
. ipconfig.sh
./stop.sh

NODE_PATH=/home/ubuntu/blockchain/mining/



#./run_cmd.sh "scp -i ~/.ssh/ssh-2022-03-24.key -r node${i} ubuntu@${ip}:${NODE_PATH}"
#./run_cmd.sh "scp -i ~/.ssh/ssh-2022-03-24.key bin/geth ubuntu@${ip}:${NODE_PATH}/node${i}/bin/"
#./run_cmd.sh "scp -i ~/.ssh/ssh-2022-03-24.key pwd.txt ubuntu@${ip}:${NODE_PATH}/node${i}/"
#./run_cmd.sh 'ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "cd ${NODE_PATH}/node${i}; nohup sh start.sh > log.txt 2>&1 &"' 


#i=0
#for ip in ${iplist[@]}
#do
#	scp -i ~/.ssh/ssh-2022-03-24.key -r node${i} ubuntu@${ip}:${NODE_PATH} 
#	scp -i ~/.ssh/ssh-2022-03-24.key bin/geth ubuntu@${ip}:${NODE_PATH}/node${i}/bin/ 
#	scp -i ~/.ssh/ssh-2022-03-24.key pwd.txt ubuntu@${ip}:${NODE_PATH}/node${i}/ 
#	ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "cd ${NODE_PATH}/node${i}; nohup sh start.sh > log.txt 2>&1 &" 
#	((i++))
#done

#./run_cmd.sh "scp -i ~/.ssh/ssh-2022-03-24.key -r node${i} ubuntu@${ip}:${NODE_PATH}"

count=0
i=0
for ip in ${iplist[@]}
do
	ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "rm -rf ${NODE_PATH}/*; mkdir -p ${NODE_PATH}/node${i}; rm -rf /home/ubuntu/.ethash; rm -rf /home/ubuntu/*log;"  &
	((count++))
	((i++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done

count=0
i=0
for ip in ${iplist[@]}
do
	scp -i ~/.ssh/ssh-2022-03-24.key -r node${i} ubuntu@${ip}:${NODE_PATH} &
	((count++))
	((i++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done

count=0
i=0
for ip in ${iplist[@]}
do
	ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "rm -rf ${NODE_PATH}/node${i}/bin; mkdir ${NODE_PATH}/node${i}/bin; rm -rf /home/ubuntu/test;" &
	((count++))
	((i++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done


count=0
i=0
for ip in ${iplist[@]}
do
	scp -i ~/.ssh/ssh-2022-03-24.key bin/geth ubuntu@${ip}:${NODE_PATH}/node${i}/bin  &
	((count++))
	((i++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done

count=0
i=0
for ip in ${iplist[@]}
do
	scp -i ~/.ssh/ssh-2022-03-24.key pwd.txt ubuntu@${ip}:${NODE_PATH}/node${i}  &
	((i++))
	((count++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done

count=0
i=0
for ip in ${iplist[@]}
do
	ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "cd ${NODE_PATH}/node${i}; nohup sh start.sh > log.txt 2>&1 &" &
	((i++))
	((count++))
done

while [ $count -gt 0 ]; do
        wait $pids
        count=`expr $count - 1`
done



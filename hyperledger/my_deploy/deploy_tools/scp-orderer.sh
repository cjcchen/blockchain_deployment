set -x

./script/gen-config.sh

. config/ip_config.sh


function sshnode() {
	count=0
	for ip in ${order_list[@]}
	do
	echo $ip
	ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "$1" &
	((count++))
	done

	while [ $count -gt 0 ]; do
		wait $pids
		count=`expr $count - 1`
	done
}

function scpnode() {
	count=0
	for ip in ${order_list[@]}
	do
		echo $ip
		scp -i ~/.ssh/ssh-2022-03-24.key -r $1 ubuntu@${ip}:$2 &
		((count++))
	done

	while [ $count -gt 0 ]; do
		wait $pids
		count=`expr $count - 1`
	done
}

sshnode "sudo mkdir -p /var/hyperledger; sudo chmod 0777 /var/hyperledger;"
sshnode "sudo chmod 0777 /var/hyperledger"
sshnode "rm -rf /home/ubuntu/hyperledger/*"
sshnode "mkdir -p /home/ubuntu/hyperledger/{script,orderer,config,peer}"



scpnode script/clear.sh  /home/ubuntu/hyperledger/script


count=0
for ip in ${order_list[@]}
do
	scp -i ~/.ssh/ssh-2022-03-24.key -r orderer${count}.example.com/*  ubuntu@${ip}:/home/ubuntu/hyperledger/orderer &
	((count++))
done

while [ $count -gt 0 ]; do
	wait $pids
	count=`expr $count - 1`
done

scpnode script/re-write_host.sh  /home/ubuntu/hyperledger/script
scpnode config/hosts  /home/ubuntu/hyperledger/config/

sshnode "cd /home/ubuntu/hyperledger/; ./script/re-write_host.sh"
sshnode "cp /etc/hosts /home/ubuntu/hyperledger/; sudo cp /home/ubuntu/hyperledger/config/new_hosts /etc/hosts;"


function sshnode1() {
	count=0
	for ip in ${list[@]}
	do
	echo $ip
	ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "$1" &
	((count++))
	done

	while [ $count -gt 0 ]; do
		wait $pids
		count=`expr $count - 1`
	done
}

function scpnode1() {
	count=0
	for ip in ${list[@]}
	do
		echo $ip
		scp -i ~/.ssh/ssh-2022-03-24.key -r $1 ubuntu@${ip}:$2 &
		((count++))
	done

	while [ $count -gt 0 ]; do
		wait $pids
		count=`expr $count - 1`
	done
}

sshnode1 "sudo mkdir -p /var/hyperledger; sudo chmod 0777 /var/hyperledger;"
sshnode1 "sudo chmod 0777 /var/hyperledger"
sshnode1 "rm -rf /home/ubuntu/hyperledger/peer"
#sshnode1 "rm -rf /home/ubuntu/hyperledger/*"
sshnode1 "mkdir -p /home/ubuntu/hyperledger/{script,orderer,config,peer}"

scpnode1 script/clear.sh  /home/ubuntu/hyperledger/script
scpnode1 script/re-write_host.sh  /home/ubuntu/hyperledger/script
scpnode1 config/hosts  /home/ubuntu/hyperledger/config/

sshnode1 "cd /home/ubuntu/hyperledger/; ./script/re-write_host.sh"
sshnode1 "cp /etc/hosts /home/ubuntu/hyperledger/; sudo cp /home/ubuntu/hyperledger/config/new_hosts /etc/hosts;"

count=0
for ip in ${list[@]}
do
scp -i ~/.ssh/ssh-2022-03-24.key -r peer${count}.org1.example.com/* ubuntu@${ip}:/home/ubuntu/hyperledger/peer/ &
((count++))
done


while [ $count -gt 0 ]; do
	wait $pids
	count=`expr $count - 1`
done


sudo cp config/new_hosts /etc/hosts
cd ..; ./scp_cli.sh

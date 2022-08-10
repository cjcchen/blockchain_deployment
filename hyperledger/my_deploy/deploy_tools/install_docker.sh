set -x
set -e

. config/ip_config.sh
#iplist=(
##10.2.0.240
#10.2.0.163
#10.2.0.208
#)

i=0
for ip in ${list[@]}
do
echo $i,$ip
if [ $i -gt 100 ]; then
ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "rm -rf /home/ubuntu/.ethash"
ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "sudo apt --fix-broken install -y; sudo apt install docker-compose -y;"
ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "sudo groupadd docker; sudo usermod -aG docker $USER;"
ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "docker pull hyperledger/fabric-ccenv:2.4;docker pull hyperledger/fabric-baseos:2.4;docker tag hyperledger/fabric-ccenv:2.4 hyperledger/fabric-ccenv:2.5; docker tag hyperledger/fabric-baseos:2.4 hyperledger/fabric-baseos:2.5"
ssh -i ~/.ssh/ssh-2022-03-24.key -n -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@${ip} "sudo chmod 666 /var/run/docker.sock;"
fi
i=$((i+1))
done




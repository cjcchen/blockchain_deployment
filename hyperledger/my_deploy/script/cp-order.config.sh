set -x

. config/ip_config.sh

ORDER_NUM=${#order_list[@]}
NUM=${#list[@]}

rm orderer*.example.com -rf
rm peer*.org1.example.com -rf

for((i=0;i<${ORDER_NUM};++i))
do
rm -rf orderer${i}.example.com
mkdir -p orderer${i}.example.com/bin
cp -r certs/ordererOrganizations/example.com/orderers/orderer${i}.example.com/* orderer${i}.example.com/
cp -r tools/start_order.sh orderer${i}.example.com/
cp -r config/orderer.yaml orderer${i}.example.com/
cp -r tools/bin/orderer orderer${i}.example.com/bin/
sed -i "s/orderer1.example.com/orderer${i}.example.com/g" orderer${i}.example.com/start_order.sh
done

for((i=0;i<$NUM;++i))
do
rm peer${i}.org1.example.com -rf
mkdir -p peer${i}.org1.example.com/bin
cp tools/bin/peer peer${i}.org1.example.com/bin
cp config/core.yaml peer${i}.org1.example.com
cp tools/start_peer.sh peer${i}.org1.example.com
sed -i "s/peer0.org1.example.com/peer${i}.org1.example.com/g" peer${i}.org1.example.com/start_peer.sh
sed -i "s/CORE_PEER_GOSSIP_BOOTSTRAP=peer${i}.org1.example.com:7051/CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051/g" peer${i}.org1.example.com/start_peer.sh
if [[ $i -eq 0 ]]; then
sed -i "s/CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051/CORE_PEER_GOSSIP_BOOTSTRAP=peer1.org1.example.com:7051/g" peer${i}.org1.example.com/start_peer.sh
fi
cp -rf certs/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/* peer${i}.org1.example.com
done

rm -fr Admin@org1.example.com
mkdir -p Admin@org1.example.com
cp -rf certs/peerOrganizations/org1.example.com/users/Admin\@org1.example.com/* Admin\@org1.example.com/
cp peer1.org1.example.com/core.yaml  Admin\@org1.example.com/
cp -rf  Admin\@org1.example.com/ User1\@org1.example.com/
rm -rf  User1\@org1.example.com/msp
rm -rf  User1\@org1.example.com/tls
cp -rf  certs/peerOrganizations/org1.example.com/users/User1\@org1.example.com/* User1\@org1.example.com/

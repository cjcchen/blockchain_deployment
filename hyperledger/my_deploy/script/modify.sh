set -x
export FABRIC_CFG_PATH=`pwd`/peer0.org1.example.com
export PEER0_ORG1_CA=${PWD}/certs/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_TLS_ENABLED=true
export CORE_CHAINCODE_EXECUTETIMEOUT=300s
export CORE_PEER_TLS_CERT_FILE=./tls/client.crt
export CORE_PEER_TLS_KEY_FILE=./tls/client.key
export CORE_PEER_ID=cli
#export CORE_LOGGING_LEVEL=INFO
export ORDERER_CA=${PWD}/certs/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export CHANNEL_NAME=syschannel

PEER_ADDS=""
. config/ip_config.sh
SVR_NUM=${#list[@]}
for((i=0;i<$SVR_NUM;++i))
do
PEER_ADDS=${PEER_ADDS}" --peerAddresses peer${i}.org1.example.com:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE"
done

CC_NAME=basic
CC_VERSION=1
CC_INIT_FCN=${7:-"NA"}
fcn_call='{"function":"'${CC_INIT_FCN}'","Args":[]}'

count=1
start=$(date +%s%N)
for((i=0;i<$count;++i))
do
#./bin/peer chaincode invoke -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "$ORDERER_CA" -C $CHANNEL_NAME -n basic $PEER_ADDS -c '{"function":"CreateAsset","Args":["2345","red", "5", "Christopher5","123"]}' --waitForEvent --waitForEventTimeout 300s
#./bin/peer chaincode invoke -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "$ORDERER_CA" -C $CHANNEL_NAME -n basic $PEER_ADDS -c '{"function":"UpdateAsset","Args":["asset4","red", "5", "Christopher5","123"]}'  --waitForEvent --waitForEventTimeout 300s
./bin/peer chaincode invoke -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "$ORDERER_CA" -C $CHANNEL_NAME -n basic $PEER_ADDS -c '{"function":"Update","Args":["6","Christopher2"]}'  --waitForEvent 
#--waitForEventTimeout 300s
#./script/pm.sh >> chain_code.log &
done
end=$(date +%s%N)
echo "run:"$(((end-start)))

#while [ $count -gt 0 ]; do
#        wait $pids
#        count=`expr $count - 1`
#done


./bin/peer chaincode query -C $CHANNEL_NAME -n basic -c '{"Args":["GetAllData"]}'

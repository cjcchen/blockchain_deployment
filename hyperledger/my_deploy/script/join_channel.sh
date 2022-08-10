. config/ip_config.sh

set -x
SVR_NUM=${#list[@]}

for((i=0;i<$SVR_NUM;++i))
do
export FABRIC_CFG_PATH=`pwd`/peer${i}.org1.example.com
export PEER0_ORG1_CA=${PWD}/certs/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer${i}.org1.example.com:7051

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_CERT_FILE=./tls/client.crt
export CORE_PEER_TLS_KEY_FILE=./tls/client.key
export CORE_PEER_TLS_ROOTCERT_FILE=./tls/ca.crt
export CORE_PEER_ID=cli
export CORE_LOGGING_LEVEL=INFO
export ORDERER_CA=${PWD}/certs/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

./bin/peer channel join -b ./channel-artifacts/genesisblock
done

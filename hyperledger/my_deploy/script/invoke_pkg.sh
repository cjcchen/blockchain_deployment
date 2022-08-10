set -x
export FABRIC_CFG_PATH=`pwd`/peer0.org1.example.com
export PEER0_ORG1_CA=${PWD}/certs/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_CERT_FILE=./tls/client.crt
export CORE_PEER_TLS_KEY_FILE=./tls/client.key
export CORE_PEER_ID=cli
export CORE_LOGGING_LEVEL=INFO
export ORDERER_CA=${PWD}/certs/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export CHANNEL_NAME=syschannel

CC_NAME=basic
CC_VERSION=1
CC_INIT_FCN=${7:-"NA"}
fcn_call='{"function":"'${CC_INIT_FCN}'","Args":[]}'

#./bin/peer chaincode instantiate -o orderer0.example.com:7050 --tls true --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -v $CC_VERSION -c '{"Args":["init"]}' -P "OR('Org1MSP.member')"


./bin/peer chaincode invoke -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "$ORDERER_CA" -C $CHANNEL_NAME -n basic --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE -c '{"function":"InitLedger","Args":["init"]}'


./bin/peer chaincode query -C $CHANNEL_NAME -n basic -c '{"Args":["GetAllData"]}'



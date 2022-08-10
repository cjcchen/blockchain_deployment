set -x
i=$1

export FABRIC_CFG_PATH=`pwd`/peer${i}.org1.example.com
export PEER0_ORG1_CA=${PWD}/certs/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
export CORE_CHAINCODE_BUILDER=hyperledger/fabric-ccenv:2.4
export TWO_DIGIT_VERSION=2.4
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer${i}.org1.example.com:7051

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_CERT_FILE=./tls/client.crt
export CORE_PEER_TLS_KEY_FILE=./tls/client.key
export CORE_PEER_ID=cli
export FABRIC_LOGGING_SPEC=INFO
export ORDERER_CA=${PWD}/certs/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export CHANNEL_NAME=syschannel

CC_SEQUENCE=${6:-"1"}
INIT_REQUIRED=""
#INIT_REQUIRED="--init-required"
CC_END_POLICY=""
iCC_COLL_CONFIG=""

CC_SRC_PATH=./code/benchmark
CC_NAME=basic
CC_VERSION=1
./bin/peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang golang --label ${CC_NAME}_${CC_VERSION}

./bin/peer lifecycle chaincode install ${CC_NAME}.tar.gz

./bin/peer lifecycle chaincode queryinstalled > log.txt

PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
echo $PACKAGE_ID
./bin/peer lifecycle chaincode approveformyorg -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG}

./bin/peer lifecycle chaincode commit -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile "$ORDERER_CA" --channelID $CHANNEL_NAME --name ${CC_NAME} peer${i}.org1.example.com:7051 --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} 

./bin/peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} 


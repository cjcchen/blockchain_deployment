export FABRIC_CFG_PATH=$PWD
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_PROFILE_ENABLED=false
export CORE_PEER_TLS_CERT_FILE=./tls/server.crt
export CORE_PEER_TLS_KEY_FILE=./tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=./tls/ca.crt
export CORE_PEER_ID=peer0.org1.example.com
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_LISTENADDRESS=0.0.0.0:7051
export CORE_PEER_CHAINCODEADDRESS=peer0.org1.example.com:7052
export CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
#export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
#export CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051
#export CORE_PEER_GOSSIP_USELEADERELECTION=true
#export CORE_PEER_GOSSIP_ORGLEADER=false
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_MSPCONFIGPATH=./msp
export CORE_OPERATIONS_LISTENADDRESS=peer0.org1.example.com:9444
export CORE_METRICS_PROVIDER=prometheus
export CHAINCODE_AS_A_SERVICE_BUILDER_CONFIG={"peername":"peer0org1"}
export CORE_CHAINCODE_EXECUTETIMEOUT=300s

killall -9 peer
./bin/peer node start

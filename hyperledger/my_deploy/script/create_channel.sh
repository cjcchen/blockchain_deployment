set -x
. config/ip_config.sh

SVR_NUM=${#order_list[@]}
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/certs/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

for((i=0;i<$SVR_NUM;++i))
do
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/orderer${i}.example.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/orderer${i}.example.com/tls/server.key

./bin/osnadmin channel join --channelID syschannel --config-block ./channel-artifacts/genesisblock -o orderer${i}.example.com:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" 

done


#set -x
. config/ip_config.sh
SVR_NUM=${#list[@]}

for((i=0;i<$SVR_NUM;++i))
do
echo "        - orderer${i}.example.com:7050"
done

for((i=0;i<$SVR_NUM;++i))
do
echo """ 
        - Host: orderer${i}.example.com
          Port: 7050
          ClientTLSCert: ../orderer${i}.example.com/tls/server.crt
          ServerTLSCert: ../orderer${i}.example.com/tls/server.crt"""
done



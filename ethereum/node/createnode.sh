


set -x

python3 create_gensis.py
. ipconfig.sh

SVR_NUM=${#iplist[@]}


for((i=0;i<${SVR_NUM};i++))
do
rm -rf node${i}/geth node${i}/keystore 
geth --datadir ./node$i init ./gensis/gensis.json; 
cp config/start.sh node${i}/
ACCOUNT_PATH=`ls node${i}/account/keystore | head -1`
ACCOUNT=${ACCOUNT_PATH:37}
echo $ACCOUNT
sed -i "s/ACCOUNT=/ACCOUNT=${ACCOUNT}/g" node${i}/start.sh
done

./scp_node.sh

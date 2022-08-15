BOOT_ADDRESS=enode://40e82dd54b84b1ec697afc8a596cf15d1b7fd98fff3a191bdc35d352b999ef11ec5dbb3256f524e6e670b5540d77dafb64803666a0f8bced9b9b29f74ff32ab6@10.2.0.110:30301

ACCOUNT=

./bin/geth --datadir "./" --networkid 12345 --http --http.addr 0.0.0.0 --http.port=12345 --http.corsdomain "*" --http.api eth,net,web3,db,net,personal,admin,shh,txpool,debug,miner --maxpeers=256 --allow-insecure-unlock --port 3001 --identity "master" --ipcdisable --metrics --metrics.influxdb --metrics.influxdb.endpoint "http://10.2.0.110:8086" --metrics.influxdb.username "geth" --metrics.influxdb.password "123456" --keystore ./account/keystore/  --unlock ${ACCOUNT} --password ./pwd.txt --cache 1024  --rpc.txfeecap 0 --rpc.gascap 0 --txpool.accountqueue 999999 --txpool.globalqueue 999999
#--miner.gasprice 100 --miner.gaslimit 60000 
#--dev --dev.period 2


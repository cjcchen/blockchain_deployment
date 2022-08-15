set -x

. ipconfig.sh
SVR_NUM=${#iplist[@]}

for((i=0; i < $SVR_NUM; ++i))
do 
	rm ./node$i/account/* -rf &
	geth --datadir ./node$i/account/  account new --password ./pwd.txt 
done

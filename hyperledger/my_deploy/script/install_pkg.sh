. config/ip_config.sh

set -x

SVR_NUM=${#list[@]}

count=0
for((i=0;i<$SVR_NUM;++i))
do
./script/install_per_pkg.sh ${i} 
((count++))
done

while [ $count -gt 0 ]; do
	wait $pids
	count=`expr $count - 1`
done

set -x

ps -ef | grep -i performance.py | awk '{ print "kill -9 "$2 }' | sh

for((i=0;i<$1; ++i))
do
	`python3 ./performance.py $i > log${i} 2>&1 &`
done

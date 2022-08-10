
NEW_HOST_FILE=config/new_hosts
rm ${NEW_HOST_FILE}
while read line
do
	sub=`echo $line | grep "example.com"`
	if [[ ${#sub}  = 0 ]];
	then
	echo $line >> ${NEW_HOST_FILE}
	fi
done <  /etc/hosts

cat config/hosts >> ${NEW_HOST_FILE}

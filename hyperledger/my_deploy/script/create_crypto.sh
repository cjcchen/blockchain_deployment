. config/ip_config.sh

CONFIG_PATH=config/crypto.yaml

echo """
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# ---------------------------------------------------------------------------
# "OrdererOrgs" - Definition of organizations managing orderer nodes
# ---------------------------------------------------------------------------
OrdererOrgs:
  - Name: Orderer
    Domain: example.com
    EnableNodeOUs: true

    Specs:""" > $CONFIG_PATH

rm config/hosts
i=0
for ip in ${order_list[@]}
do
echo """      - Hostname: orderer${i}
        SANS:
          - ${ip}""" >> $CONFIG_PATH

echo """${ip} orderer${i}.example.com """ >> config/hosts
((i++))
done

echo """
# ---------------------------------------------------------------------------
# "PeerOrgs" - Definition of organizations managing peer nodes
# ---------------------------------------------------------------------------
PeerOrgs:
  - Name: Org1
    Domain: org1.example.com
    EnableNodeOUs: true

    Template:
      Count: ${#list[@]}
      SANS:""" >> $CONFIG_PATH
i=0
for ip in ${list[@]}
do
echo """        - ${ip}""" >> $CONFIG_PATH
echo """${ip} peer${i}.org1.example.com """ >> config/hosts
((i++))
done

echo """
    Users:
      Count: 1
""" >> $CONFIG_PATH

FABRIC_CFG_PATH=${PWD}
./bin/configtxgen -profile TwoOrgsApplicationGenesis -outputBlock ./channel-artifacts/genesisblock -channelID syschannel -configPath ./config

./bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID syschannel -asOrg Org1MSP -configPath ./config


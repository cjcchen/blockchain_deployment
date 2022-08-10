set -x
rm -rf certs

# generate crypto.yaml
./script/create_crypto.sh

# generate certs
./bin/cryptogen generate --config=./config/crypto.yaml --output ./certs


# copy the certs to separate foldes
./script/cp-order.config.sh


# generate host file
./script/re-write_host.sh

# generate the gensis block
./script/gensis.sh



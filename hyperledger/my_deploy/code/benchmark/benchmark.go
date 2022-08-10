/*
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"log"
	"benchmark/chaincode"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	bmChaincode, err := contractapi.NewChaincode(&chaincode.SmartContract{})
	if err != nil {
		log.Panicf("Error creating asset-transfer-basic chaincode: %v", err)
	}

	if err := bmChaincode.Start(); err != nil {
		log.Panicf("Error starting asset-transfer-basic chaincode: %v", err)
	}
}

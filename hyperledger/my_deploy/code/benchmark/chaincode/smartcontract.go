package chaincode

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing an KV
type SmartContract struct {
	contractapi.Contract
}

type KVInfo struct {
	Value          string `json:"Value"`
	ID             string `json:"ID"`
}

// InitLedger adds a base set of assets to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	var infos []*KVInfo
	for i :=0; i < 10000; i++ {
		info := KVInfo {ID: strconv.Itoa(i), Value: ""};
		infos = append(infos, &info)
	}

	for _, info := range infos {
		data, err := json.Marshal(info)
		if err != nil {
			return err
		}

		err = ctx.GetStub().PutState(info.ID, data)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
	}

	return nil
}

// CreateAsset issues a new asset to the world state with given details.
func (s *SmartContract) Update(ctx contractapi.TransactionContextInterface, id string, value string) error {
	// overwriting original asset with new asset
	info := KVInfo {
		ID:             id,
		Value:          value,
	}
	data, err := json.Marshal(info)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, data)
}

// AssetExists returns true when asset with given ID exists in world state
func (s *SmartContract) KeyExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	data, err := ctx.GetStub().GetState(id)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}

	return data!= nil, nil
}

// GetAllAssets returns all assets found in world state
func (s *SmartContract) GetAllData(ctx contractapi.TransactionContextInterface) ([]*KVInfo, error) {
	// range query with empty string for startKey and endKey does an
	// open-ended query of all assets in the chaincode namespace.
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var infos []*KVInfo
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var info KVInfo
		err = json.Unmarshal(queryResponse.Value, &info)
		if err != nil {
			return nil, err
		}
		if len(info.Value) > 0 {
			infos= append(infos, &info)
		}
	}

	return infos, nil
}

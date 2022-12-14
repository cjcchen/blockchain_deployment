package chaincode_test

import (
	"encoding/json"
	"fmt"
	"testing"
	"benchmark/chaincode/mocks"
	"benchmark/chaincode"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/hyperledger/fabric-protos-go/ledger/queryresult"
	"github.com/stretchr/testify/require"
)

//go:generate counterfeiter -o mocks/transaction.go -fake-name TransactionContext . transactionContext
type transactionContext interface {
	contractapi.TransactionContextInterface
}

//go:generate counterfeiter -o mocks/chaincodestub.go -fake-name ChaincodeStub . chaincodeStub
type chaincodeStub interface {
	shim.ChaincodeStubInterface
}

//go:generate counterfeiter -o mocks/statequeryiterator.go -fake-name StateQueryIterator . stateQueryIterator
type stateQueryIterator interface {
	shim.StateQueryIteratorInterface
}

func TestInitLedger(t *testing.T) {
	chaincodeStub := &mocks.ChaincodeStub{}
	context := &mocks.TransactionContext{}
	context.GetStubReturns(chaincodeStub)

	contract := chaincode.SmartContract{}
	err := contract.InitLedger(context)
	require.NoError(t, err)

	chaincodeStub.PutStateReturns(fmt.Errorf("failed inserting key"))
	err = contract.InitLedger(context)
	require.EqualError(t, err, "failed to put to world state. failed inserting key")
}

func TestUpdate(t *testing.T) {
	chaincodeStub := &mocks.ChaincodeStub{}
	transactionContext := &mocks.TransactionContext{}
	transactionContext.GetStubReturns(chaincodeStub)

	expectedAsset := &chaincode.KVInfo{ID: "asset1"}
	bytes, err := json.Marshal(expectedAsset)
	require.NoError(t, err)

	chaincodeStub.GetStateReturns(bytes, nil)
	contract := chaincode.SmartContract{}
	err = contract.Update(transactionContext, "", "")
	require.NoError(t, err)

	chaincodeStub.GetStateReturns(nil, nil)
	err = contract.Update(transactionContext, "asset1", "1234")
	require.EqualError(t, err, "the key asset1 does not exist")

	chaincodeStub.GetStateReturns(nil, fmt.Errorf("unable to retrieve asset"))
	err = contract.Update(transactionContext, "asset1", "2345")
	require.EqualError(t, err, "failed to read from world state: unable to retrieve asset")
}

func TestGetAll(t *testing.T) {
	info := &chaincode.KVInfo{ID: "asset1", Value: "test"}
	bytes, err := json.Marshal(info)
	require.NoError(t, err)

	iterator := &mocks.StateQueryIterator{}
	iterator.HasNextReturnsOnCall(0, true)
	iterator.HasNextReturnsOnCall(1, false)
	iterator.NextReturns(&queryresult.KV{Value: bytes}, nil)

	chaincodeStub := &mocks.ChaincodeStub{}
	transactionContext := &mocks.TransactionContext{}
	transactionContext.GetStubReturns(chaincodeStub)

	chaincodeStub.GetStateByRangeReturns(iterator, nil)
	contract := &chaincode.SmartContract{}
	infos, err := contract.GetAllData(transactionContext)
	require.NoError(t, err)
	require.Equal(t, []*chaincode.KVInfo{info}, infos)

	iterator.HasNextReturns(true)
	iterator.NextReturns(nil, fmt.Errorf("failed retrieving next item"))
	infos, err = contract.GetAllData(transactionContext)
	require.EqualError(t, err, "failed retrieving next item")
	require.Nil(t, infos)

	chaincodeStub.GetStateByRangeReturns(nil, fmt.Errorf("failed retrieving all assets"))
	infos, err = contract.GetAllData(transactionContext)
	require.EqualError(t, err, "failed retrieving all assets")
	require.Nil(t, infos)
}

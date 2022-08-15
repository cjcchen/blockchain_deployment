import os
import json

template="""
{
  "config": {
    "chainId": 12345,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "ethash": {}
  },
  "nonce": "0x0",
  "timestamp": "0x62c65219",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit": "0x47b760",
  "difficulty": "0x2080000",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "alloc": {
  },
  "number": "0x0",
  "gasUsed": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "baseFeePerGas": null
}
"""

#"difficulty": "0x1880000",
  #"difficulty": "0x480000",
def readAccount():
    accounts = []
    for root, dirs, files in os.walk("./"):
        for f in files:
            if f[0:3] == "UTC":
                acc = f[f.rfind("--")+2:]
                print( "find:",f,acc)
                accounts.append(acc)
    return accounts

accounts = readAccount()
y = json.loads(template)

alloc_list = {}
for acc in accounts:
    alloc_list[acc]={ "balance": "0x200000000000000000000000000000000000000000000000000000000000000" }
y["alloc"]=alloc_list
with open("gensis/gensis.json", 'w') as f_new:
    json.dump(y, f_new,indent=4)

from web3 import Web3
from web3.middleware import geth_poa_middleware
import time
import random
import threading

iplist=[
        "10.2.0.110",
        "10.2.0.161",
        "10.2.0.69",
#"10.2.0.39",
#"10.2.0.20",
#"10.2.0.159",
#"10.2.0.44",
#"10.2.0.4",
#"10.2.0.99",
#"10.2.0.80",
#"10.2.0.84",
#"10.2.0.2",
#"10.2.0.241",
#"10.2.0.83",
#"10.2.0.172",
#"10.2.0.132",
#"10.2.0.121",
#"10.2.0.143",
#"10.2.0.24"
]

def GetMaster():
    master = Web3(Web3.HTTPProvider("http://{}:12345".format(iplist[0])))
    assert(master.isConnected())
    return master

def GetMiner(ip):
    miner = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
    if not miner.isConnected():
        print("miner not connected:",ip)
    assert(miner.isConnected())
    return miner


def MakeCluster():
    master = Web3(Web3.HTTPProvider("http://{}:12345".format(iplist[0])))
    assert(master.isConnected())
    if len(master.geth.admin.peers()) >= len(iplist) -1:
        return

    #enode: "enode://8411bb223db2eabe042f69b65fbbbbf7346d87f719c1f452b6822c65ee0f246cbd67e800a94836ccab6324003f2634f4b32fddd10e08b94807e748ef94fb6b43@127.0.0.1:3001",

    def AddPeer(ip, enode):
        enode = enode[:enode.rfind("@")+1]+ip+enode[enode.rfind(":"):]
        print("Add enode:",enode)
        master.geth.admin.add_peer(enode)
    
    for ip in iplist[1:]:
        w3 = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
        print(w3)
        #w3.middleware_stack.inject(geth_poa_middleware, layer=0)
        print("ip:{}".format(ip))
        print(w3.isConnected())
        print(w3.geth.admin.node_info().enode)
        print(w3.geth.admin.node_info().id)
        assert(w3.isConnected())

        AddPeer(ip, w3.geth.admin.node_info().enode)

    while True:
        time.sleep(5)
        done = True
        for ip in iplist:
            w3 = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
            print("ip:{} peers:{}".format(ip, len(master.geth.admin.peers())))
        if len(master.geth.admin.peers()) < len(iplist)-1:
            done = False
        if done:
            break



def CheckPeers():
    for ip in iplist:
        w3 = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
        print("ip:{} peers:{}".format(ip, len(w3.geth.admin.peers())))
        for peer in w3.geth.admin.peers():
            print(peer)

def GetTxn():
    master= GetMaster()
    account=master.eth.accounts[0]
    print("sent: ",master.eth.getTransactionCount(account))
    #master.eth.getPendingTransactions(account)

def CountTPS():
    master= GetMaster()
    def count():
        block = master.eth.get_block('latest')
        laster_num = block.number
        start = time.time()
        for _ in range(6*4):
            state = master.eth.syncing
            print("sync:{}".format(state))
            print("tx pool:{}".format(master.geth.txpool.status()))
            block = master.eth.get_block('latest')
            current_num = block.number
            now = time.time()
            pt = now - start
            start = time.time()
            print("current_num:{}, difficulty:{}, pt:{}".format(current_num, block.difficulty, pt))

            total = 0
            for i in range(laster_num+1, current_num+1):
                ct = master.eth.get_block_transaction_count(i)
                print("block:{} trnasactions:{}".format(i, ct))
                total += ct
            if pt > 0:
                print("block:{} count:{}, avg:{}, last:{}".format(current_num,total, total/pt, laster_num))

            laster_num = current_num

            time.sleep(10)

    t = threading.Thread(target=count)
    t.start()
    t.join()

def StartMine():
    for ip in iplist[1:]:
        w3 = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
        w3.geth.miner.start()

def StopMine():
    for ip in iplist:
        w3 = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
        w3.geth.miner.stop()


count_done=False
def SendTxn(acc_idx):
    #t = threading.Thread(target=count)
    acc_idx = acc_idx%(len(iplist))
    #for i in range(5000):
    master = GetMiner(iplist[acc_idx])
    for i in range(len(master.eth.accounts)):
        master.geth.personal.unlockAccount(master.eth.accounts[i],"123456")
        print("un lock account:{}".format(master.eth.accounts[i]))

    while not count_done:
        try:
            idx = random.randint(0, len(iplist)-1)
            if idx == acc_idx:
                continue
            #print("idx=",idx)
            member = GetMiner(iplist[idx])

            idx2 = random.randint(0, len(master.eth.accounts)-1)

            param={}
            param["from"] = master.eth.accounts[idx2]
            param["to"] = member.eth.accounts[0]
            param["value"] = 10000
            param["gas"] = 30000
            param["gasPrice"] = 1
            #print("send txn:{}".format(param))
            master.eth.sendTransaction(param)
        except:
            pass
        time.sleep(0.001)
        continue


MakeCluster()
#CheckPeers()

#SendTxn()
StartMine()
t1=[]
for i in range(1,3):
    t1.append(threading.Thread(target=SendTxn, args=(i,)))
for t in t1:
    t.start()
time.sleep(5)
t2 = threading.Thread(target=CountTPS)
t2.start()
#CountTPS()
#CountTPS()
t2.join()
count_done=True
for t in t1:
    t.join()
StopMine();
GetTxn()

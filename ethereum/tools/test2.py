from web3 import Web3
import sys
import web3
from web3.auto import w3
from web3.middleware import geth_poa_middleware
import time
import random
import threading
from threading import Thread
import time
from metrics import Influxdb

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

infx = Influxdb()

def GetMaster():
    master = Web3(Web3.HTTPProvider("http://{}:12345".format(iplist[0])))
    assert(master.isConnected())
    return master

def GetMiner(ip):
    miner = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
    print("miner is connected:",ip, miner.isConnected())
    assert(miner.isConnected())
    return miner

accounts = []
client = None
client_account = None
client_ip = None
def InitClient(idx):
    global client,client_account,client_ip
    client = GetMiner(iplist[idx])
    client_ip = iplist[idx]
    client_account = client.eth.accounts[0]
    client.geth.personal.unlockAccount(client_account,"123456")

def GetAccount(idx):
    for ip in iplist:
        if ip == iplist[idx]:
            continue

        member = GetMiner(ip)
        accounts.append(member.eth.accounts[0])
        print("get account:{}".format(accounts[-1]))

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
    while True:
        time.sleep(1)
        print("client peers:{}".format(len(client.geth.admin.peers())))
        if len(client.geth.admin.peers()) > 0:
            break

def CountTPS():
    def count():

        last_total_trans = 0
        last_block_size  = 0
        last_total_latency = 0


        start = time.time()
        for _ in range(6*4):
            local_latency_total = latency_total
            local_block_count = block_count
            local_trans_count = trans_count
            current = time.time()

            total_trans = sum(local_trans_count) - last_total_trans
            total_latency = sum(local_latency_total) - last_total_latency
            total_block_size = sum(local_block_count) - last_block_size

            print("tps:{} latnecy:{} block size:{}".format(total_trans/(current-start), total_latency/(current-start), total_block_size/(current-start)))
            start = current
            last_block_size = sum(local_block_count)
            last_total_latency = sum(local_latency_total)
            last_total_trans = sum(local_trans_count)

            time.sleep(10)

    t = threading.Thread(target=count)
    t.start()
    t.join()

def StartMine():
    print("start mining")
    client.geth.miner.start()

def StopMine():
    client.geth.miner.stop()

latency_total = []
block_count = []
trans_count = []
Txn_In_Flight = 5

count_done=False
def SendTxn():
    txn_send_time = {}
    latency= {}

    send_size = 5
    print("start send:",client_account)
    def send_some(send_size):
        if count_done:
            return
        try:
            num=send_size
            print("miner:{} send:{}".format(client_account, num))
            while True:
                idx = random.randint(0, len(accounts)-1)

                param={}
                param["from"] = client_account
                param["to"] = accounts[idx]
                param["value"] = 10000
                param["gas"] = 30000
                param["gasPrice"] = 1
                #print("send txn:{}".format(param))
                txn = client.eth.sendTransaction(param)
                print("send:{}".format(Web3.toJSON(txn)))
                txn_send_time[txn] = time.time()
                num-=1
                if num == 0:
                    break
        except:
            print("send data fail",iplist[acc_idx]) 
            pass

    def handle_event(event):
        hash_value = Web3.toJSON(event)
        try:
            block = client.eth.get_block(event)
        except Exception as e:
            print("get block fail,{}".format(e))
            return
        miner = block.miner
        if miner == client_account:
            print("miner:{} recv:{} size:{} txn:{} diff:{} height:{}".format( client_ip, hash_value, block.size, len(block.transactions), block.difficulty, block.number))
            infx.InsertBlock(client_ip, len(iplist), block.number, block.difficulty, block.size)
            if len(block.transactions) > 0:
                trans_count.append(len(block.transactions))
                block_count.append(block.size)
            done = False
            for txn in block.transactions:
                #print("self block:",txn, txn in txn_send_time)
                if  txn in txn_send_time:
                    latency[txn] = time.time() - txn_send_time[txn]
                    del txn_send_time[txn]
                    latency_total.append(latency[txn])
                    infx.InsertTxn(client_ip, len(iplist),latency[txn])
                    #print("latency:",Web3.toJSON(txn),latency[txn])
                    done = True
            if done:
                send_size = len(block.transactions)
                send_some(send_size)
        #else:
        #    print("recv other{}, self acc:{}".format(miner, miner_acc))
        #send_some()

    def log_loop(event_filter, poll_interval):
        while not count_done:
            for event in event_filter.get_new_entries():
                handle_event(event)
            time.sleep(poll_interval)

    block_filter = client.eth.filter('latest')
    worker = Thread(target=log_loop, args=(block_filter, 5), daemon=True)
    worker.start()
    send_some(Txn_In_Flight)
    worker.join()    

if __name__ == '__main__':
    idx = int(sys.argv[1])
    GetAccount(idx)
    InitClient(idx)
    CheckPeers()
    StartMine()

    t1=threading.Thread(target=SendTxn)
    t1.start()
    time.sleep(5)
    print("start monitoring")
    t2 = threading.Thread(target=CountTPS)
    t2.start()
    t2.join()
    count_done=True
    t1.join()
    StopMine();

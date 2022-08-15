from web3 import Web3
import glog
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
from config import iplist


latency_total = []
block_count = []
trans_count = []
Txn_In_Flight = 1280


infx = Influxdb(Txn_In_Flight)

def GetMaster():
    master = Web3(Web3.HTTPProvider("http://{}:12345".format(iplist[0])))
    assert(master.isConnected())
    return master

def GetMiner(ip):
    miner = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
    glog.info("miner {} is connected:{}".format(ip, miner.isConnected()))
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
    #client.geth.personal.unlockAccount(client_account,"123456")

def GetAccount(idx):
    i = 0
    for ip in iplist:
        if ip == iplist[idx]:
            continue

        member = GetMiner(ip)
        accounts.append(member.eth.accounts[0])
        glog.info("get account:{}, idx:{}".format(accounts[-1],i))
        i=i+1

def CountTPS():
    def count():

        last_total_trans = 0
        last_block_size  = 0
        last_total_latency = 0
        last_block = 0

        start = time.time()
        for _ in range(6*60):
            block = client.eth.get_block('latest')
            infx.InsertBlockHeight(client_ip, len(iplist), block.number, last_block)

            local_latency_total = latency_total
            local_block_count = block_count
            local_trans_count = trans_count
            current = time.time()

            total_trans = sum(local_trans_count) - last_total_trans
            total_latency = sum(local_latency_total) - last_total_latency
            total_block_size = sum(local_block_count) - last_block_size

            glog.info("tps:{} latnecy:{} block size:{} bps:{}".format(total_trans/(current-start), total_latency/(current-start), total_block_size/(current-start), (block.number-last_block)/(current-start)))
            start = current
            last_block = block.number
            last_block_size = sum(local_block_count)
            last_total_latency = sum(local_latency_total)
            last_total_trans = sum(local_trans_count)

            time.sleep(10)

    t = threading.Thread(target=count)
    t.start()
    t.join()

def StartMine():
    glog.info("start mining")
    client.geth.miner.start()

def StopMine():
    client.geth.miner.stop()


count_done=False
def SendTxn():
    txn_send_time = {}
    latency= {}

    glog.info("start send:{}".format(client_account))
    def per_send_some(send_size):
        if count_done:
            return
        while True:
            try:
                num=send_size
                glog.info("ip:{} miner:{} send:{}".format(client_ip, client_account, num))
                infx.SendTxn(client_ip, len(iplist), num)
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
                    txn_send_time[txn] = time.time()
                    num-=1
                    assert(num>=0)
                    #glog.info("??? send:{}, time:{} left:{}".format(Web3.toJSON(txn), txn_send_time[txn], num))
                    if num == 0:
                        break
                    #time.sleep(0.001)
            except Exception as e:
                glog.error("send data fail:ip{} error:{}".format(client_ip,e))
                time.sleep(1)
                continue
            break
    def send_some(send_size):
        #per_send_some(send_num)
        ths = []
        while send_size > 0:
            send_num = 512
            if send_num > send_size:
                send_num = send_size
            send_size = send_size - send_num
            t=threading.Thread(target=per_send_some, args=(send_num,))
            t.start()
            ths.append(t)
        for th in ths:
            th.join()

    empty_block_count=0
    def handle_event(event):
        hash_value = Web3.toJSON(event)
        try:
            block = client.eth.get_block(event)
        except Exception as e:
            glog.error("get block fail,{}".format(e))
            return
        miner = block.miner
        glog.info("miner:{} recv:{} size:{} txn:{} diff:{} height:{}".format( client_ip, hash_value, block.size, len(block.transactions), block.difficulty, block.number))
        if miner == client_account:
            #glog.info("miner:{} recv:{} size:{} txn:{} diff:{} height:{}".format( client_ip, hash_value, block.size, len(block.transactions), block.difficulty, block.number))
            infx.InsertTxnNum(client_ip, len(iplist), len(block.transactions))
            infx.InsertBlock(client_ip, len(iplist), block.number, block.difficulty, block.size)
            if len(block.transactions) > 0:
                trans_count.append(len(block.transactions))
                block_count.append(block.size)
        if len(block.transactions) > 0:
            infx.InsertTPS(client_ip, len(iplist), len(block.transactions))
        done = False
        done_num = 0
        nonlocal txn_send_time 
        for txn in block.transactions:
            #print("self block:",txn, txn in txn_send_time)
            if  txn in txn_send_time:
                latency[txn] = time.time() - txn_send_time[txn]
                latency_total.append(latency[txn])
                infx.InsertTxn(client_ip, len(iplist),latency[txn])
                done_num=done_num+1
                #glog.info("txn:{} latency:{}, start:{}, now:{}, left:{} block height:{}".format(Web3.toJSON(txn),latency[txn], txn_send_time[txn], time.time(), len(txn_send_time)-1, block.number))
                done = True
                del txn_send_time[txn]
            else:
                glog.info("txn:{} not found left:{}, block:{}".format(Web3.toJSON(txn),len(txn_send_time)-1, block.number))
        nonlocal empty_block_count
        glog.info("empty block:{}".format(empty_block_count))
        if len(block.transactions) == 0:
            empty_block_count = empty_block_count + 1
        else:
            empty_block_count = 0

        if len(txn_send_time) == 0:
        #if len(txn_send_time) == 0 or empty_block_count > 30:
            empty_block_count = 0
            txn_send_time = {}
            send_some(Txn_In_Flight)

        #else:
        #    print("recv other{}, self acc:{}".format(miner, miner_acc))
        #send_some()

    def log_loop(event_filter, poll_interval):
        while not count_done:
            for event in event_filter.get_new_entries():
                handle_event(event)
            #glog.info("slpp poll:{}".format(poll_interval))
            time.sleep(poll_interval)

    block_filter = client.eth.filter('latest')
    worker = Thread(target=log_loop, args=(block_filter, 0.001), daemon=True)
    worker.start()
    send_some(Txn_In_Flight)
    worker.join()    

if __name__ == '__main__':
    idx = int(sys.argv[1])
    glog.info("run ip:{}".format(iplist[idx]))
    #CheckPeers(idx)
    GetAccount(idx)
    InitClient(idx)
    StartMine()
    #time.sleep(30)
    #CheckPeers(idx)
    t1s=[]
    if idx <= 0:
        for _ in range(1):
            t1=threading.Thread(target=SendTxn)
            t1.start()
            t1s.append(t1)
    time.sleep(5)
    glog.info("start monitoring")
    t2 = threading.Thread(target=CountTPS)
    t2.start()
    t2.join()
    count_done=True
    if idx == 0:
        for t1 in t1s:
            t1.join()
    StopMine();

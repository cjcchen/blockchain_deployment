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


def MakeCluster():
    enodes={}
    for ip in iplist:
        w3 = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
        print(w3, ip)
        assert(w3.isConnected())

        enode = w3.geth.admin.node_info().enode
        enode = enode[:enode.rfind("@")+1]+ip+enode[enode.rfind(":"):]

        enodes[ip]=enode
    need_ct = len(iplist)-1
    print("incode len:{}, need:{}".format(len(enodes), need_ct))
    #need_ct = len(iplist)/2
    def add():
        for idx, ip in enumerate(iplist):
            w3 = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
            if len(w3.geth.admin.peers()) >= need_ct:
                continue
            #for j in range(30):
            for j in range(len(iplist)):
                next_ip = iplist[(idx+j+1)%len(iplist)]
                w3.geth.admin.add_peer(enodes[next_ip])
            '''
            num=0
            for (key,value) in enodes.items():
                if key == ip:
                    continue
                print("ip:{} add :{}".format(ip, value))
                w3.geth.admin.add_peer(value)
                num=num+1
                if num >= need_ct:
                    break
            '''
    add() 
    while True:
        time.sleep(1)
        done = True
        for ip in iplist:
            w3 = Web3(Web3.HTTPProvider("http://{}:12345".format(ip)))
            glog.info("ip:{} peers:{}".format(ip, len(w3.geth.admin.peers())))
            if len(w3.geth.admin.peers()) < need_ct:
                done = False
        if done:
            break
        add()

MakeCluster()

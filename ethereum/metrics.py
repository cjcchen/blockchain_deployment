from influxdb import InfluxDBClient
import time
import glog


class Influxdb:
    def __init__(self, inflight):
        self.client_ = InfluxDBClient(host='10.2.0.110', port=8086, username='geth', password='123456',ssl=False, verify_ssl=False)
        assert(self.client_ != None)
        self.client_.switch_database('geth')
        self.inflight_ = inflight

    def InsertBlock(self, ip, num, block_height, difficulty, block_size):
        json = [{
            "measurement": "block",
            "tags": {
                "user": ip,
                "total": num,
                "inflight": self.inflight_
            },
            #"time": time.time() ,
            "fields": {
                "height": block_height,
                "size": block_size,
                "difficulty":difficulty,
            }
        }]
        self.client_.write_points(json)

    def InsertBlockHeight(self, ip, num, block_height, last_hight):
        json = [{
            "measurement": "block_state",
            "tags": {
                "user": ip,
                "total": num,
                "inflight": self.inflight_
            },
            #"time": time.time() ,
            "fields": {
                "height": block_height,
                "committed_block":block_height-last_hight,
                "nodes": num,
            }
        }]
        self.client_.write_points(json)

    def InsertTxnNum(self, ip, num, num_txn):
        json = [{
            "measurement": "txn",
            "tags": {
                "user": ip,
                "total": num,
                "inflight": self.inflight_
            },
            #"time": time.time() ,
            "fields": {
                "num_txn": num_txn,
            }
        }]
        self.client_.write_points(json)

    def InsertTxn(self, ip, num, latency):
        json = [{
            "measurement": "txn",
            "tags": {
                "user": ip,
                "total": num,
                "inflight": self.inflight_
            },
            #"time": time.time() ,
            "fields": {
                "latency": latency,
            }
        }]
        self.client_.write_points(json)

    def InsertTPS(self, ip, num, txn):
        json = [{
            "measurement": "txn",
            "tags": {
                "user": ip,
                "total": num,
                "inflight": self.inflight_,
                "diff": 6
            },
            #"time": time.time() ,
            "fields": {
                "total_txn": txn,
            }
        }]
        glog.info("add tps:{}".format(txn))
        self.client_.write_points(json)

    def SendTxn(self, ip, num, send_num):
        json = [{
            "measurement": "txn",
            "tags": {
                "user": ip,
                "total": num,
                "inflight": self.inflight_
            },
            "fields": {
                "send_txn": send_num,
            }
        }]
        self.client_.write_points(json)

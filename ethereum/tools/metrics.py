from influxdb import InfluxDBClient
import time


class Influxdb:
    def __init__(self):
        self.client_ = InfluxDBClient(host='10.2.0.110', port=8086, username='geth', password='123456',ssl=False, verify_ssl=False)
        assert(self.client_ != None)
        self.client_.switch_database('geth')

    def InsertBlock(self, ip, num, block_height, difficulty, block_size):
        json = [{
            "measurement": "block",
            "tags": {
                "user": ip,
                "total": num,
            },
            #"time": time.time() ,
            "fields": {
                "height": block_height,
                "size": block_size,
                "difficulty":difficulty,
            }
        }]
        self.client_.write_points(json)

    def InsertTxn(self, ip, num, latency):
        json = [{
            "measurement": "txn",
            "tags": {
                "user": ip,
                "total": num,
            },
            #"time": time.time() ,
            "fields": {
                "latency": latency,
            }
        }]
        self.client_.write_points(json)

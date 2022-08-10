NUM=$1

echo """
global:
  scrape_interval: 1s
  external_labels:
    monitor: 'devopsage-monitor'

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
""" > hy_2.0.yml

for((i=0;i<$NUM;++i))
do
echo """
  - job_name: "orderer${i}"
    static_configs:
      - targets: ["orderer${i}.example.com:9443"]
""" >> hy_2.0.yml
done

for((i=0;i<$NUM;++i))
do
echo """
  - job_name: "peer${i}_org1"
    static_configs:
      - targets: ["peer${i}.org1.example.com:9444"]
""" >> hy_2.0.yml
done

for((i=0;i<3;++i))
do
echo """
  - job_name: "cli${i}"
    static_configs:
      - targets: ["cli${i}.com:9445"]
""" >> hy_2.0.yml
done

echo """
  - job_name: cadvisor
    scrape_interval: 5s
    static_configs:
      - targets: ['cadvisor:8080']
  - job_name: node
    static_configs:
      - targets: ['node-exporter:9100']
""" >> hy_2.0.yml

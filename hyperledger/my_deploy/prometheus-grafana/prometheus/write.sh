
list=(
"10.0.1.220"
"10.0.1.136" 
"10.0.1.183"
"10.0.1.214"
"10.0.1.91"
"10.0.1.201"
"10.0.1.170"
"10.0.1.251"
"10.0.1.138"
"10.0.1.6"
"10.0.1.105"
"10.0.1.254"
"10.0.1.164"
"10.0.1.124"
"10.0.1.212"
"10.0.1.21"
)
echo """
global:
  scrape_interval: 1s
  external_labels:
    monitor: 'devopsage-monitor'

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
""" > a.yml

i=1
for ip in ${list[@]}
do
echo """
  - job_name: "peer${i}"
    static_configs:
      - targets: ["${ip}:9445"]
""" >> a.yml
((i++))
done

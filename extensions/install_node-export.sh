#!/bin/sh
# download node_exporter and decompress
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.0.1.linux-amd64.tar.gz
cd node_exporter-1.0.1.linux-amd64/
cp node_exporter /usr/local/bin
cd .. && rm -rf node_exporter*

# add systemctl service
bash -c "cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF"

# start node_exporter
systemctl daemon-reload && systemctl start node_exporter && systemctl enable node_exporter

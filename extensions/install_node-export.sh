#!/bin/sh
#ref : https://teamsmiley.github.io/2020/01/17/prometheus/
# download node_exporter and decompress
wget -P /tmp/ https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xvfz /tmp/node_exporter-1.0.1.linux-amd64.tar.gz
cp /tmp/node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin
rm -rf /tmp/node_exporter*

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

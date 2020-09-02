# install prometheus node-exporter
sudo wget -P \
  /tmp/ https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz; \
  cd /tmp; \
  sudo tar xvfz node_exporter-1.0.1.linux-amd64.tar.gz; \
  sudo cp /tmp/node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin; \
  sudo rm -rf /tmp/node_exporter*

# add systemctl service
sudo bash -c "cat << EOF > /etc/systemd/system/node_exporter.service
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
sudo systemctl daemon-reload && sudo systemctl start node_exporter && sudo systemctl enable node_exporter

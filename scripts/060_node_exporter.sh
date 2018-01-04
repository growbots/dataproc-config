#!/usr/bin/env bash

dir=$(pwd)

cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=node_exporter
Requires=network-online.target

[Service]
ExecStart=/opt/node_exporter/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

cd /tmp/
wget https://github.com/prometheus/node_exporter/releases/download/v0.15.2/node_exporter-0.15.2.linux-amd64.tar.gz
tar -xvf node_exporter-0.15.2.linux-amd64.tar.gz
mkdir -p /opt/node_exporter
cp node_exporter-0.15.2.linux-amd64/node_exporter /opt/node_exporter/

systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service

cd $dir

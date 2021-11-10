#!/bin/sh
#### 가상 머신 생성 알림 설정
# WEBHOOK_ADDRESS=""
# # 슬랙 메세지 함수
# function slack_message(){
#     # $1 : message
#     # $2 : true=good, false=danger
#
#     COLOR="danger"
#     if $2 ; then
#         COLOR="good"
#     fi
#     curl -s -d 'payload={"attachments":[{"color":"'"$COLOR"'","pretext":"<!channel> *lab*","text":"*HOST* : '"$HOSTNAME"' \n*MESSAGE* : '"$1"'"}]}' $WEBHOOK_ADDRESS > /dev/null 2>&1
# }
#
# slack_message "$HOSTNAME 가상 머신을 생성하는 중입니다." true

# change date timezone into Asia/seoul
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
sudo timedatectl set-timezone Asia/Seoul

# selinux disable
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=disable/' /etc/selinux/config && sudo setenforce 0
################################################################################
# change the ssh listening port
sudo sed -i 's/^Port 22$/Port 16215/' /etc/ssh/sshd_config
sudo sed -i 's/^#Banner \/etc\/issue.net$/Banner \/etc\/issue.net/' /etc/ssh/sshd_config
# add a login banner
sudo bash -c "cat << EOF > /etc/issue.net
*******************************************************************************
*                                                                             *
*                                                                             *
*  [[[ WARNING ]]] This Machine Is ISCREAMmedia Inc's Property.               *
*                                                                             *
*  A Person Autherized By SIGONGmedia Inc Can Use This Machine.               *
*  Even If You Are Autherized, You Can Only Utilize To The Purpose.           *
*  Any Illegal Action May Results In Severe Civil And Criminal Penalties.     *
*                                                                             *
*                                                                             *
*  [[[ 경 고 ]]] 이 장비는 아이스크림미디어의 자산입니다.                     *
*  이 장비는 승인된 사용자만 접속해야합니다.                                  *
*  허가된 목적이 아닌 다른 목적으로 시스템을 사용해선 안 됩니다.              *
*  불법적인 행동에는 민형사상 법적 책임이 따릅니다.                           *
*                                                                             *
*                                                                             *
*******************************************************************************
EOF"

# change a "#PrintMotd yes" into "PrintMotd no"
sudo sed -i 's/^#PrintMotd yes$/PrintMotd no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Add a "welcome banner"
sudo curl -o /usr/bin/dynmotd https://raw.githubusercontent.com/sohwaje/Powershell_for_azure/master/extensions/motd.sh
sleep 5
sudo sh -c "chmod +x /usr/bin/dynmotd"
sudo sh -c "echo /usr/bin/dynmotd > /etc/profile.d/motd.sh"
################################################################################
# Tunning Kernel parameter values
sudo swapoff -a
sudo sed -e '/swap/ s/^#*/#/' -i /etc/fstab

sudo bash -c "cat << EOF > /etc/sysctl.conf
vm.swappiness=0
net.ipv4.ip_forward=1
fs.file-max=10000000
net.core.somaxconn=65535
net.core.netdev_max_backlog=16777216
net.core.rmem_max=134217728
net.core.wmem_max=67108864
net.core.rmem_default=67108864
net.core.wmem_default=67108864
net.core.optmem_max=67108864
net.ipv4.ip_local_port_range=1024 65535
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_max_syn_backlog=16777216
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_mem=134217728 134217728 134217728
net.ipv4.tcp_rmem=10240 87380 134217728
net.ipv4.tcp_wmem=10240 87380 134217728
net.ipv4.tcp_fin_timeout=10
net.ipv4.tcp_max_orphans=262144
net.ipv4.tcp_synack_retries=5
net.ipv4.tcp_syn_retries=5
net.ipv4.tcp_keepalive_time=60
net.ipv4.tcp_keepalive_probes=3
net.ipv4.tcp_keepalive_intvl=10
net.ipv4.tcp_sack=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.udp_rmem_min=65536
net.ipv4.udp_wmem_min=65536
net.unix.max_dgram_qlen=100
vm.dirty_ratio=40
vm.dirty_background_ratio=10
vm.max_map_count=262144
net.ipv4.tcp_fack=1
kernel.msgmnb=65536
kernel.msgmax=65536
vm.overcommit_memory=1
EOF"
sudo /sbin/sysctl -p /etc/sysctl.conf

# filedescriptor
sudo bash -c "cat << EOF > /etc/security/limits.conf
*          soft    nproc     unlimited
*          hard    nproc     unlimited
*          soft    nofile    65536
*          hard    nofile    65536
EOF"
sudo bash -c "cat << EOF > /etc/security/limits.d/20-nproc.conf
*          soft    nproc     unlimited
*          hard    nproc     unlimited
root       soft    nproc     unlimited
root       hard    nproc     unlimited
EOF"

# customize "login-prompt"
echo "export PS1=\`hostname\`'-\$LOGNAME \$PWD>'" | sudo tee -a /etc/profile
echo "export PS1=\"[\$LOGNAME@\`hostname\`:\$PWD]\"" | sudo tee -a /root/.bashrc
################################################################################

# update system, install software and add yum repository
sudo apt-get update 
sudo apt-get install openjdk-8-jdk \
git \
python3 \
python3-pip

# install a docker
## Setup the repository
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
## install a docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# sudo groupadd docker
sudo usermod -aG docker azureuser

# install a docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# python3 pip.
# sudo curl https://bootstrap.pypa.io/get-pip.py | python3

# install and import python3 psutil
sudo python3 -m pip install -U psutil

# install prometheus node-exporter
sudo wget -P \
  /tmp/ https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz; \
  cd /tmp; \
  sudo tar xvfz node_exporter-1.0.1.linux-amd64.tar.gz; \
  sudo cp /tmp/node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin; \
  sudo rm -rf /tmp/node_exporter*
#
# # add systemctl service
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

sudo systemctl start node_exporter.service
# slack_message "$HOSTNAME 가상 머신을 생성하였습니다." true

#!/bin/sh
# 커널 파라미터 튜닝
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
net.ipv4.tcp_max_orphans=5
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

# 파일 디스크립터 개수 수정
sudo bash -c "cat << EOF > /etc/security/limits.conf
* soft  nproc  unlimited
* hard  nproc  unlimited
* soft  nofile  65536
* hard  nofile  65536
EOF"

# 로그인 프롬프트 변경
sudo echo "export PS1=\`hostname\`'-\$LOGNAME \$PWD>'" >> /etc/profile
sudo echo """export PS1=\"[\$LOGNAME@\`hostname\`:\$PWD]\"" >> /root/.bashrc

# OS 업데이트
sudo yum update -y

# 리포지토리 업데이트
yum -y install yum-plugin-priorities
yum -y install epel-release
yum -y install centos-release-scl-rh centos-release-scl
yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm


# 인스톨 openjdk 8
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel

# 인스톨 docker
sudo curl -s https://get.docker.com | sudo sh && systemctl start docker && systemctl enable docker

# 인스톨 아파(테스트 용도)
sudo yum install -y httpd
sudo sed -i 's/^Listen 80$/Listen 38080/' /etc/httpd/conf/httpd.conf
sudo echo "Test-Page" > /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd

# SSH root login 수정
#sudo sed -i '/^#PermitRootLogin yes$/PermitRootLogin no' /etc/ssh/sshd_config

# SSH port 수정
sudo sed -i 's/^#Port 22$/Port 16215/' /etc/ssh/sshd_config
sudo sed -i 's/^#Banner none$/Banner \/etc\/issue.net/' /etc/ssh/sshd_config

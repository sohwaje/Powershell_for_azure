#!/bin/sh
sed -i 's/^#Banner none$/Banner \/etc\/issue.net/' /etc/ssh/sshd_config
# add a login banner
bash -c "cat << EOF > /etc/issue.net
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
sed -i 's/^#PrintMotd yes$/PrintMotd no/' /etc/ssh/sshd_config
systemctl restart sshd

# Add a "welcome banner"
curl -o /usr/bin/dynmotd https://raw.githubusercontent.com/sohwaje/Powershell_for_azure/master/extensions/motd.sh
chmod +x /usr/bin/dynmotd && echo "/usr/bin/dynmotd" >> /etc/profile

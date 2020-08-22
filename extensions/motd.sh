#!/bin/bash

# Installation:
#
# 1.   vim /etc/ssh/sshd_config
#      PrintMotd no
#
# 2.   vim /etc/pam.d/login
#      # session optional pam_motd.so
#
# 3.   vim /etc/profile
#      /usr/bin/dynmotd # Place at the bottom
#
# 4.   Then of course drop this file at
#      /usr/bin/dynmotd
#

USER=`whoami`
HOSTNAME=`uname -n`
ROOT=`df -Ph | grep root | awk '{print $4}' | tr -d '\n'`
HOME=`df -Ph | grep home | awk '{print $4}' | tr -d '\n'`
BACKUP=`df -Ph | grep backup | awk '{print $4}' | tr -d '\n'`

MEMORY1=`free -t -m | grep "buffers/cache" | awk '{print $3" MB";}'`
MEMORY2=`free -t -m | grep "Mem" | awk '{print $2" MB";}'`
PSA=`ps -Afl | wc -l`

# time of day
HOUR=$(date +"%H")
if [ $HOUR -lt 12  -a $HOUR -ge 0 ]
then    TIME="morning"
elif [ $HOUR -lt 17 -a $HOUR -ge 12 ]
then    TIME="afternoon"
else
    TIME="evening"
fi

#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))

#System load
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

echo -e "\e[48;5;16m                                         \e[48;5;52m \e[48;5;160m  \e[48;5;16m      \e[48;5;1m  \e[48;5;16m                            \e[0m
\e[48;5;16m                                         \e[48;5;1m \e[48;5;160m          \e[48;5;124m \e[48;5;16m                           \e[0m
\e[48;5;16m                                          \e[48;5;59m  \e[48;5;16m \e[48;5;52m \e[48;5;124m \e[48;5;160m    \e[48;5;16m                             \e[0m
\e[48;5;16m                                        \e[48;5;234m \e[48;5;59m  \e[48;5;58m \e[48;5;16m  \e[48;5;88m \e[48;5;160m   \e[48;5;16m                              \e[0m
\e[48;5;16m                                       \e[48;5;235m \e[48;5;59m       \e[48;5;94m \e[48;5;160m  \e[48;5;16m                              \e[0m
\e[48;5;16m                                            \e[48;5;233m \e[48;5;59m    \e[48;5;94m \e[48;5;16m                              \e[0m
\e[48;5;16m                                              \e[48;5;232m \e[48;5;16m \e[48;5;52m \e[48;5;234m \e[48;5;16m                      \e[48;5;233m \e[48;5;232m \e[48;5;16m      \e[0m
\e[48;5;52m  \e[48;5;16m      \e[48;5;52m \e[48;5;160m \e[48;5;124m \e[48;5;16m                                         \e[48;5;232m \e[48;5;16m                \e[48;5;59m  \e[48;5;16m  \e[48;5;235m \e[48;5;16m      \e[0m
\e[48;5;160m \e[48;5;124m \e[48;5;16m       \e[48;5;160m    \e[48;5;1m \e[48;5;16m  \e[48;5;124m \e[48;5;160m \e[48;5;1m \e[48;5;16m   \e[48;5;160m  \e[48;5;88m \e[48;5;124m \e[48;5;16m \e[48;5;160m  \e[48;5;16m \e[48;5;52m \e[48;5;160m \e[48;5;16m  \e[48;5;52m \e[48;5;16m \e[48;5;1m \e[48;5;160m \e[48;5;52m  \e[48;5;160m \e[48;5;52m \e[48;5;1m \e[48;5;160m \e[48;5;124m \e[48;5;16m \e[48;5;160m \e[48;5;124m \e[48;5;16m  \e[48;5;59m  \e[48;5;232m \e[48;5;58m \e[48;5;59m \e[48;5;235m \e[48;5;3m \e[48;5;59m \e[48;5;234m \e[48;5;16m \e[48;5;59m \e[48;5;235m \e[48;5;234m \e[48;5;59m \e[48;5;1m \e[48;5;232m \e[48;5;59m  \e[48;5;234m \e[48;5;59m  \e[48;5;16m \e[48;5;59m \e[48;5;58m \e[48;5;16m   \e[48;5;235m \e[48;5;59m \e[48;5;58m \e[0m
\e[48;5;160m \e[48;5;124m \e[48;5;16m          \e[48;5;1m \e[48;5;160m  \e[48;5;16m \e[48;5;160m \e[48;5;124m \e[48;5;16m    \e[48;5;160m \e[48;5;52m \e[48;5;16m   \e[48;5;160m  \e[48;5;124m   \e[48;5;52m  \e[48;5;160m \e[48;5;124m \e[48;5;52m \e[48;5;160m \e[48;5;1m \e[48;5;52m \e[48;5;160m \e[48;5;1m \e[48;5;16m \e[48;5;160m \e[48;5;88m \e[48;5;16m \e[48;5;160m  \e[48;5;16m  \e[48;5;59m  \e[48;5;16m \e[48;5;3m \e[48;5;59m \e[48;5;233m \e[48;5;235m \e[48;5;59m \e[48;5;236m \e[48;5;59m     \e[48;5;52m \e[48;5;235m \e[48;5;59m \e[48;5;234m \e[48;5;16m \e[48;5;59m  \e[48;5;16m \e[48;5;59m \e[48;5;58m \e[48;5;232m \e[48;5;59m  \e[48;5;3m \e[48;5;59m  \e[0m
\e[48;5;160m \e[48;5;124m \e[48;5;16m      \e[48;5;52m \e[48;5;160m     \e[48;5;16m   \e[48;5;160m  \e[48;5;124m  \e[48;5;16m \e[48;5;160m \e[48;5;52m \e[48;5;16m   \e[48;5;1m \e[48;5;160m \e[48;5;124m  \e[48;5;160m \e[48;5;16m \e[48;5;1m \e[48;5;160m    \e[48;5;52m  \e[48;5;160m \e[48;5;1m \e[48;5;16m \e[48;5;160m \e[48;5;88m \e[48;5;16m \e[48;5;160m  \e[48;5;16m  \e[48;5;59m  \e[48;5;16m \e[48;5;3m \e[48;5;59m \e[48;5;233m \e[48;5;235m \e[48;5;59m \e[48;5;235m \e[48;5;233m \e[48;5;59m  \e[48;5;58m \e[48;5;59m \e[48;5;16m  \e[48;5;1m \e[48;5;59m \e[48;5;58m \e[48;5;59m \e[48;5;58m \e[48;5;16m \e[48;5;59m \e[48;5;58m \e[48;5;232m \e[48;5;59m  \e[48;5;58m \e[48;5;59m  \e[0m"

echo "Good $TIME $USER"

echo "
===========================================================================
 - Hostname............: $HOSTNAME
 - Release.............: `cat /etc/redhat-release`
 - Users...............: Currently `users | wc -w` user(s) logged on
===========================================================================
 - Current user........: $USER
 - CPU usage...........: $LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min)
 - Memory used.........: $MEMORY1 / $MEMORY2
 - Swap in use.........: `free -m | tail -n 1 | awk '{print $3}'` MB
 - Processes...........: $PSA running
 - System uptime.......: $upDays days $upHours hours $upMins minutes $upSecs seconds
 - Disk space ROOT.....: $ROOT remaining
 - Disk space HOME.....: $HOME remaining
 - Disk space BACK.....: $BACKUP remaining
===========================================================================
"

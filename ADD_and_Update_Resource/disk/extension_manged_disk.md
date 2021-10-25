# 디스크 사이즈 변경

az vm deallocate --resource-group ISCREAM --name EFK

az disk list --resource-group ISCREAM --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' --output table

az disk update --resource-group ISCREAM --name demo-datadisk-0 --size-gb 100

az vm start --resource-group ISCREAM --name EFK


# trouble shooting
## 실제 디스크 사이즈는 변경되었지만 OS에서 변경된 사이즈가 적용되지 않을 때가 있다.

- OS에 인식한 디스크 사이즈
```
# fdisk -l
...
Disk /dev/sdc: 536.9 GB, 536870912000 bytes, 1048576000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disk label type: dos
Disk identifier: 0x00000000

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1               1   209715199   104857599+  ee  GPT
Partition 1 does not start on physical sector boundary.
```

- OS에 인식한 파티션 사이즈
```
$ df -hT
Filesystem     Type      Size  Used Avail Use% Mounted on
devtmpfs       devtmpfs  7.8G     0  7.8G   0% /dev
tmpfs          tmpfs     7.8G     0  7.8G   0% /dev/shm
tmpfs          tmpfs     7.8G  9.2M  7.8G   1% /run
tmpfs          tmpfs     7.8G     0  7.8G   0% /sys/fs/cgroup
/dev/sda2      xfs        30G  4.2G   25G  15% /
/dev/sdc1      xfs       100G   97G  3.5G  97% /data   <================= 500GB 증설하였으나 반영되지 않음.
```

## 조치
- 파티션 삭제(실제 파티션 테이블을 삭제하는 것이므로 데이터가 삭제되지 않음)
```
$ fdisk /dev/sdc
...
Command (m for help): d
Selected partition 1
Partition 1 is deleted

Command (m for help): p
Disk /dev/sdc: 536.9 GB, 536870912000 bytes, 1048576000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disk label type: dos
Disk identifier: 0x00000000

   Device Boot      Start         End      Blocks   Id  System
```
- 파티션 생성
```
Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended

Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-1048575999, default 2048): [Enter]
Last sector, +sectors or +size{K,M,G} (2048-1048575999, default 1048575999): [Enter]

Partition 1 of type Linux and of size 500 GiB is set


Command (m for help): p
   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1            2048  1048575999   524286976   83  Linux

Command (m for help): w
```

- 파티션 증설(재부팅 없이 적용)
```
$ partprobe /dev/sdc

$ xfs_growfs /dev/sda2
meta-data=/dev/sdc1              isize=512    agcount=4, agsize=6553472 blks
         =                       sectsz=4096  attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=26213888, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=12799, version=2
         =                       sectsz=4096  sunit=1 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```

- 증설된 파티션 확인
```
$ df -hT
Filesystem     Type      Size  Used Avail Use% Mounted on
devtmpfs       devtmpfs  7.8G     0  7.8G   0% /dev
tmpfs          tmpfs     7.8G     0  7.8G   0% /dev/shm
tmpfs          tmpfs     7.8G  9.2M  7.8G   1% /run
tmpfs          tmpfs     7.8G     0  7.8G   0% /sys/fs/cgroup
/dev/sda2      xfs        30G  4.2G   25G  15% /
/dev/sdc1      xfs       500G   97G  404G  20% /data
```
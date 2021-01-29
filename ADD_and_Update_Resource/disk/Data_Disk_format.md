# Linux VM에 디스크 추가후 포맷
***
## [여기](https://github.com/sohwaje/Powershell_for_azure/blob/master/ADD_and_Update_Resource/Add-DataDisk-VM.ps1)를 참조하여 데이터 디스크를 VM에 추가한다.

###[1] 디스크 찾기
```
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"
```

###[2] 디스크 포멧
```
sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
sudo mkfs.xfs /dev/sdc1
sudo partprobe /dev/sdc1
```

###[3] 디스크 마운트
```
sudo mkdir /data
sudo mount /dev/sdc1 /data
```

###[4] 디스크 UUID 확인
```
sudo blkid
```

###[5] /etc/fstab 편집
```
vi nano /etc/fstab
UUID=33333333-3b3b-3c3c-3d3d-3e3e3e3e3e3e   /datadrive   xfs   defaults,nofail   1   2
```

###[6] 마운트
```
mount -a
```

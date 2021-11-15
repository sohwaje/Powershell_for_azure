#!/bin/sh
#[1] 백업 파일 위치(FROM_DRI), 백업 파일을 저장할 위치(TO_DIR)
BACKUPDIR=/data/backup

#[2] 만료된 백업 파일 삭제
find $BACKUPDIR -type f -mtime +6 | sort | xargs rm -f

#[3] gitlab 백업 시작
gitlab-rake gitlab:backup:create

#[3] gitlab 백업이 성공하면 FROM_DIR에서 TO_DIR에 백업 파일을 저장한다.
if [ $? -eq 0 ];then
    yes|cp -arpf /etc/gitlab/gitlab.rb $BACKUPDIR
    yes|cp -arpf /etc/gitlab/gitlab-secrets.json $BACKUPDIR
else
    exit 9
fi
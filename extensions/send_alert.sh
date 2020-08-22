#!/bin/sh
########### #################################################################
# 컨테이너 실행 -> 앱 URL 체크 -> 성공 또는 실패 메시지를 slack 채널로 보낸다. #
#############################################################################

# health check URL과 문자열
STRINGS="Hello Yusung?"
URL="http://127.0.0.1:3000"

# Slack 웹 훅주소
WEBHOOK_ADDRESS='https://'

# 슬랙으로 메시지 보내기 함수
slack_message(){
    # $1 : message
    # $2 : true=good, false=danger

    if [ $2 = false ] ; then
        COLOR="danger"
        icon_emoji=":scream:"
    else
        COLOR="good"
        icon_emoji=":smile:"
    fi
    curl -s -d 'payload={
      "attachments":
      [
        {"color":"'"$COLOR"'",
         "title":"Corp : i-SCREAMedia",
         "pretext":"<!channel> *NODEJS DEPLOY INFORMATION*",
         "text":"*HOST* : '"$HOSTNAME"'\n*MESSAGE* : '"$1"' '"$icon_emoji"'"}
      ]
  }' $WEBHOOK_ADDRESS > /dev/null 2>&1
}

# 임시파일 생성 함수
CREATE_TMPFILE(){
  mktemp /tmp/tmp.XXXXXX
}

# health check를 위한 curl 명령어 함수
DOWNLOAD_URL(){
  curl -L ${URL} -o ${TMPFILE} 2>/dev/null
}

# curl에서 문자열 추출
Match(){
  grep "${STRINGS}" "${TMPFILE}"
}

# 문자열 비교 후 슬랙으로 메시지 보내는 함수
check_url(){
  TMPFILE=$(CREATE_TMPFILE)
  DOWNLOAD_URL
  MATCH_CHRACTER=$(Match)
  if [ "$MATCH_CHRACTER" = "$STRINGS" ]; then
    slack_message "container is running " true  # 성공
    rm -f "${TMPFILE}"
    exit 0
  else
    slack_message "failure" false               # 실패
    rm -f "${TMPFILE}"
    exit 1
  fi
}

check_url

# 가상머신 확장 집합 구성하기

1. 가상머신 확장 집합의 기반 가상 머신을 생성한다.
2. 생성된 가상 머신을 프로덕션 환경에 맞게 소프트웨어를 설치하고 어플리케이션을 업데이트 한다.
- 생성된 가상 머신(Linux) 아래 명령어를 통해 Deprovision을 진행한다.
- Deprovision은 고유 UUID를 삭제한다. 삭제하지 않으면 동일한 UUID 때문에 오류가 생겨날 수 있다.
- +user 매개 변수는 마지막 프로비전된 사용자 계정을 제거합니다. VM에 사용자 계정 자격 증명을 유지하려면 -deprovision만 사용

```
sudo waagent -deprovision+user

```

```
sudo waagent -deprovision+user

```


3. 모든 업데이트가 완료된 가상 머신의 이미지를 생성한다.
4. 생성된 이미지를 사용하여 가상머신 스케일 셋을 생성한다.


# 가상머신 확장 집합의 이미지 업데이트
1. 기존 이미지를 통해 가상 머신을 생성한다.
2. app을 배포한다.
3. 다시 이미지를 생성한다.
4. 파워쉘 또는 azure cli를 사용해 이미지를 업데이트 한다.

# 가상 보호 정책
- 스케일아웃으로 부터 가상머신이 삭제되는 것을 보호한다.

# 가상머신 확장 집합 스케일 아웃 모니터링
```
while      true                                                                                                                                  
do
sleep 1
az vmss list-instances --resource-group ISCREAM --name vmss-iscream --output table
done

```

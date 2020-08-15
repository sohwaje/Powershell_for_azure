# 이 모듈을 설치하기 위해서는 az.Monitor 모듈을 설치하고 로드해야 한다.
# CPU 로드가 5분간 70%를 초과할 경우  New-AzureRmAutoscaleRule을 사용하여 확장 집합의 VM 인스턴스 수를 늘리는 규칙
# 규칙이 트리거되면 VM 인스턴스 수가 3만큼 늘어난다.
# ref : https://docs.microsoft.com/ko-kr/azure/virtual-machine-scale-sets/scripts/powershell-sample-enable-autoscale

################################# 변수 설정 #####################################
$ResourceGroupName = "ISCREAM"
$vmss_name         = "vmss-gaudium"
$location          = "koreacentral"
################################################################################
#                               스케일아웃 룰 설정
################################################################################
# 아래 명령어를 통해 vmss의 MetricResourceId를 알아낸다.
$MetricResourceId = Get-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -VMScaleSetName $vmss_name | select Id

# CPU 부하가 5분간 70%를 초과할 경우 확장 집합의 VM 인스턴스 수를 3개로 늘리는 규칙
$myRuleScaleOutv2 = New-AzAutoscaleRule `
  -MetricName "Percentage CPU" `
  -MetricResourceId $MetricResourceId `
  -TimeGrain 00:01:00 `
  -MetricStatistic "Average" `
  -TimeWindow 00:05:00 `
  -Operator "GreaterThan" `
  -Threshold 80 `
  -ScaleActionDirection "Increase" `
  -ScaleActionScaleType "ChangeCount" `
  -ScaleActionValue 3 `
  -ScaleActionCooldown 00:05:00

# CPU 부하가 5분 간 30% 미만을 경우 VM의 수를 1개로 줄이는 규칙
$myRuleScaleInv2 = New-AzAutoscaleRule `
  -MetricName "Percentage CPU" `
  -MetricResourceId $MetricResourceId `
  -Operator "LessThan" `
  -MetricStatistic "Average" `
  -Threshold 40 `
  -TimeGrain 00:01:00 `
  -TimeWindow 00:05:00 `
  -ScaleActionCooldown 00:05:00 `
  -ScaleActionDirection "Decrease" `
  -ScaleActionScaleType "ChangeCount" `
  -ScaleActionValue 1

# 자동 스케일 아웃 프로파일 생성
$myScaleProfilev2 = New-AzAutoscaleProfile `
  -DefaultCapacity 2  `
  -MaximumCapacity 10 `
  -MinimumCapacity 2 `
  -Rule $myRuleScaleOutv2,$myRuleScaleInv2 `
  -Name "autoprofilev2"

# 자동 스케일 아웃을 VMSS에 적용한다.
Add-AzAutoscaleSetting `
  -Location $location `
  -Name "autosettingv2" `
  -ResourceGroupName $ResourceGroupName `
  -TargetResourceId $MetricResourceId `
  -AutoscaleProfile $myScaleProfilev2

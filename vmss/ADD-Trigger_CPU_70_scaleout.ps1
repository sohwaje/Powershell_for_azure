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
# CPU 부하가 5분간 70%를 초과할 경우 확장 집합의 VM 인스턴스 수를 3개로 늘리는 규칙
$myRuleScaleOut = New-AzAutoscaleRule `
  -MetricName "Percentage CPU" `
  -MetricResourceId /subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Compute/virtualMachineScaleSets/vmss-gaudium `
  -TimeGrain 00:01:00 `
  -MetricStatistic "Average" `
  -TimeWindow 00:05:00 `
  -Operator "GreaterThan" `
  -Threshold 70 `
  -ScaleActionDirection "Increase" `
  -ScaleActionScaleType "ChangeCount" `
  -ScaleActionValue 3 `
  -ScaleActionCooldown 00:05:00

# CPU 부하가 5분 간 30% 미만을 경우 VM의 수를 1개로 줄이는 규칙
$myRuleScaleIn = New-AzAutoscaleRule `
  -MetricName "Percentage CPU" `
  -MetricResourceId /subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Compute/virtualMachineScaleSets/vmss-gaudium `
  -Operator "LessThan" `
  -MetricStatistic "Average" `
  -Threshold 30 `
  -TimeGrain 00:01:00 `
  -TimeWindow 00:05:00 `
  -ScaleActionCooldown 00:05:00 `
  -ScaleActionDirection "Decrease" `
  -ScaleActionScaleType "ChangeCount" `
  -ScaleActionValue 1

# 자동 스케일 아웃 프로파일 생성. -Name:기본 프로파일
$myScaleProfile = New-AzAutoscaleProfile `
  -DefaultCapacity 1  `
  -MaximumCapacity 10 `
  -MinimumCapacity 1 `
  -Rule $myRuleScaleOut,$myRuleScaleIn `
  -Name "autoprofilev1"

# 자동 스케일 아웃을 VMSS에 적용한다. -Name:자동 크기 조정 설정 이름
Add-AzAutoscaleSetting `
  -Location $location `
  -Name "autosetting" `
  -ResourceGroupName $ResourceGroupName `
  -TargetResourceId /subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Compute/virtualMachineScaleSets/vmss-gaudium `
  -AutoscaleProfile $myScaleProfile

# 트리거를 활용한 가상머신 자동 확장 설정 제거
################################# 변수 설정 #####################################
$ResourceGroupName             = "ISCREAM"
$autoscaleSetname           = "autosettingv2"
$location                      = "koreacentral"
################################################################################
Remove-AzAutoscaleSetting `
  -Name $autoscaleSetname `
  -ResourceGroupName $ResourceGroupName

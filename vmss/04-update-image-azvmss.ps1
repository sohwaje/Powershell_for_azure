# 가상 머신 확장 집합에 대한 이미지 업데이트

$ResourceGroupName = "ISCREAM"
$vmss_name         = "vmss-iscream"

# 확장 집합 속성 보기
Get-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -VMScaleSetName $vmss_name

# 확장 집합 인스턴스 보기
Get-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -VMScaleSetName $vmss_name `
  -InstanceView

# 확장 집합 인스턴스의 가상머신 모델 보기
Get-AzVmssVM `
  -ResourceGroupName $ResourceGroupName `
  -VMScaleSetName $vmss_name `
  -InstanceId 1 # 인스턴스의 번호

# 사용자 지정 이미지를 업데이트(-ImageReferenceID는 이미지 -> 속성을 확인한다.)
Update-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -VMScaleSetName $vmss_name `
  -ImageReferenceId /subscriptions/64268000-4de0-460d-9cc0-5b7730789327/resourceGroups/ISCREAM/providers/Microsoft.Compute/images/vmssimg-api

  # VMSS 인스턴스를 최신으로 업그레이드
  Update-AzVmssInstance `
    -ResourceGroupName $ResourceGroupName `
    -VMScaleSetName $vmss_name `
    -InstanceId 1

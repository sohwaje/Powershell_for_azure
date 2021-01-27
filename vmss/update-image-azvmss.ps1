# 가상 머신 확장 집합에 대한 이미지 업데이트

$ResourceGroupName = "ISCREAM"
$vmss_name         = "exampl-vmss"

$vmss = Get-AzVmss `
  -ResourceGroupName $ResourceGroupName `
  -VMScaleSetName $vmss_name

# 새로운 이미지로 vmss 업데이트 -> 업데이트가 끝나면 포탈에서 인스턴스를 업그레이드 해야 한다.
Update-AzVmss `
    -ResourceGroupName $ResourceGroupName `
    -VMScaleSetName $vmss_name  `
    -ImageReferenceId /subscriptions/{subscriptions}/resourceGroups/ISCREAM/providers/Microsoft.Compute/images/vmss-template-image-ver2

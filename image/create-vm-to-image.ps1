# 이미지에서 가상머신 만들기

New-AzVm `
    -ResourceGroupName "ISCREAM" `
    -Name "vmsstemplate" `
    -ImageName "StdNokeyIMG-centos7" `
    -Location "koreacentral" `
    -VirtualNetworkName "Hi-Class" `
    -SubnetName "SEI-Subnet" `
    -SecurityGroupName "vmsstemplate-NSG" `
    -OpenPorts 16215

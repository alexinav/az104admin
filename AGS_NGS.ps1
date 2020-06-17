#APPLICATION SECURITY GROUP

Login-AzureRmAccount

$RG = "zGroup"
$location = "westeurope"

$webASG = New-AzureRmApplicationSecurityGroup -ResourceGroupName $RG -Name "webASG" -Location $location
$sqlASG = New-AzureRmApplicationSecurityGroup -ResourceGroupName $RG -Name "sqlASG" -Location $location

$webRule = New-AzureRmNetworkSecurityRuleConfig `
    -Name "AllowHttps" `
    -Access Allow `
    -Protocol Tcp `
    -Direction outbound `
    -Priority 1500 `
    -SourceApplicationSecurityGroupId $webASG.id `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange 443

$sqlRule = New-AzureRmNetworkSecurityRuleConfig `
    -Name "AllowSQL" `
    -Access Allow `
    -Protocol Tcp `
    -Direction outbound `
    -Priority 1000 `
    -SourceApplicationSecurityGroupId $sqlASG.id `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange 1433    

$NSG = New-AzureRmNetworkSecurityGroup -ResourceGroupName $RG -Location $location `
    -Name "ASGtestNSG" -SecurityRules $webRule, $sqlRule

$VNET = Get-AzureRmVirtualNetwork -Name "MyVNet" -ResourceGroupName $RG

Set-AzureRmVirtualNEtworkSubnetConfig -Name default -VirtualNetwork $vnet `
    -NetworkSecurityGroupId $NSG.Id -AddressPrefix '10.0.0.0/16'
Set-AzureRmVirtualNEtwork -VirtualNetwork $VNET

$webNIC = Get-AzureRmNetworkInterkace -Name vm1NIC -ResourceGroupName $RG
$webNIC.IpConfigurations[0].ApplicationSecurityGroup = $webASG
Set-AzureRMNetworkInterface -NetworkInterface $webNIC

$sqlNIC = Get-AzureRmNetworkInterkace -Name vm2NIC -ResourceGroupName $RG
$sqlNIC.IpConfigurations[0].ApplicationSecurityGroup = $sqlASG
Set-AzureRMNetworkInterface -NetworkInterface $sqlNIC



#CREATE NEW NSG
#NAME testNSG
#RESOURCE GROUP NEW RG2
#GO TO RULES 
#INBOUND SECURITY RULES
#ADD
#SOURCE "APPLICATION SECURITY GROUP"
#SELECT "sqlASG"
#BE CAREFULL 
#VIRTUAL MACHINE THAT YOU ASSOCIATED WITH ASG" NEED TO BE IN THE SAME VNET
#DISK ENCRYPTION

$RG = "xGroup"
$location = "westeurope"

Resigter-AzureRmResourceProvider -ProviderNamespace "Microsoft.KeyVault"
New-AzureRmResourceGroup -Location $location -Name $RG

$keyVaultName = "psKeyVault7837"
New-AzureRmKeyVault -Location $location `
    -ResourceGroupName $RG `
    -VaultName $keyVaultName `
    -EnabledForDiskEncryption

Add-AzureKeyVaultKey -VaultName $keyVaultName `
    -Name "ADEKEY" `
    -Destination "Software"

$appName = "ADE-APP"


$securePassword = ConvertTo-SecureString -String "114rrwesNY" -AsPlainText -Force


$app = New-AzureRmADApplication -DisplayName $appName `
    -HomePage "https://ade.ps.local" `
    -IdentifierUris "https://ade.ps/ade" `
    -Password $securePassword
    
New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId

Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName `
    -ServicePrincipalName $app.ApplicationId `
    -PermissionsToKeys "WrapKey" `
    -PermissionsToSecrets "Set"

$keyVault = Get-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $RG;
$diskEncryptionKeyVaultUrl =$keyVault.VaultUri;
$keyVaultResourceId = $keyVault.ResourceId;
$keyEncryptionKeyUrl = (Get-AzureKeyVaultKey -VaultName $keyVaultName -Name ADEKEY).Key.Kid

Set-AzureRmVMDiskEncryptionExtension -ResourceGroupNamev$RG `
    -VMName "managedserver" `
    -AadClientID $app.ApplicationId `
    -AadClientSecret (New-Object PSCredential "jim@jimw.info", $securePassword).GetNetworkCredential().Password `
    -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl `
    -DiskEncryptionKeyVaultId $keyVaultResourceId `
    -KeyEncryptionKeyUrl $keyEncryptionKeyUrl `
    -KeyEncryptionKeyVaultId $keyVaultResourceId

Get-AzureRmVMDiskEncryptionStatus -ResourceGroupName $RG -VMName "managedserver"
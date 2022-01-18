'PSCloudScript for OOBEDeploy BH'
'iex (irm oobedeploybh.ps1.osdeploy.com)'

#=================================================
#   Block WinPE
#=================================================
if ($env:SystemDrive -eq 'X:')
{
    Write-Warning 'This PSCloudScript cannot be run from WinPE'
    Start-Sleep -Seconds 5
    exit
}
#=================================================
#   Require OOBE
#=================================================
if ($env:UserName -ne 'defaultuser0')
{
    Write-Warning 'This PSCloudScript must be run from OOBE'
    Start-Sleep -Seconds 5
    exit
}
#=================================================
#	Set-ExecutionPolicy
#=================================================
if ((Get-ExecutionPolicy) -ne 'RemoteSigned')
{
    Write-Host -ForegroundColor Cyan 'Set PowerShell ExecutionPolicy to RemoteSigned'
    Set-ExecutionPolicy RemoteSigned -Force
}
#=================================================
#	NuGet
#=================================================
$PackageProvider = Get-PackageProvider
if (-not ($PackageProvider | Where-Object {$_.Name -eq 'NuGet'}))
{
    Write-Host -ForegroundColor Cyan 'Install PackageProvider NuGet'
    Install-PackageProvider -Name NuGet -Force
}
#=================================================
#	Trust PSGallery
#=================================================
$PSRepository = Get-PSRepository -Name PSGallery
if ($PSRepository)
{
    if ($PSRepository.InstallationPolicy -ne 'Trusted')
    {
        Write-Host -ForegroundColor Cyan 'Trust PSGallery'
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
}
#=================================================
#	PowerShellGet
#=================================================
if ((Get-Module PowerShellGet).version -lt [System.Version]'2.2.5.0')
{
    Write-Host -ForegroundColor Cyan 'Install PowerShell Module PowerShellGet'
    Install-Module PowerShellGet -Force
}
#=================================================
#	PackageManagement
#=================================================
if ((Get-Module PackageManagement).version -lt [System.Version]'1.4.7.0')
{
    Write-Host -ForegroundColor Cyan 'Install PowerShell Module PackageManagement'
    Install-Module PackageManagement -Force
}
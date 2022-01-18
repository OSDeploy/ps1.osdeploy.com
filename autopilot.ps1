'PSCloudScript for Autopilot Requirements'
'iex (irm autopilot.ps1.osdeploy.com)'

#=================================================
#   Block WinPE
#=================================================
if ($env:SystemDrive -eq 'X:')
{
    Write-Warning 'PSCloudScript cannot be run from WinPE'
    Start-Sleep -Seconds 5
    break
}
#=================================================
#   Require OOBE
#=================================================
if ($env:UserName -ne 'defaultuser0')
{
    Write-Warning 'PSCloudScript must be run from OOBE'
    Start-Sleep -Seconds 5
    break
}
#=================================================
#	Set-ExecutionPolicy
#=================================================
if ((Get-ExecutionPolicy) -ne 'RemoteSigned')
{
    Write-Host -ForegroundColor Cyan 'Set-ExecutionPolicy RemoteSigned'
    Set-ExecutionPolicy RemoteSigned -Force
}
#=================================================
#	PackageManagement
#=================================================
if (Get-Module -Name PackageManagement -ListAvailable | Where-Object {$_.Version -ge '1.4.7'}) {
    Write-Host -ForegroundColor Cyan 'PackageManagement 1.4.7 or greater is installed'
}
else {
    Write-Host -ForegroundColor Cyan 'Install-Package PackageManagement'
    Install-Package -Name PackageManagement -MinimumVersion 1.4.7 -Force -Confirm:$false -Source PSGallery
}
#=================================================
#	PowerShellGet
#=================================================
if (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'}) {
    Write-Host -ForegroundColor Cyan 'PowerShellGet 2.2.5 or greater is installed'
}
else {
    Write-Host -ForegroundColor Cyan 'Install-Package PowerShellGet'
    Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery
}
#=================================================
#	NuGet
#=================================================
Import-Module PackageManagement,PowerShellGet -Force
$PackageProvider = Get-PackageProvider -Name NuGet -ErrorAction Ignore
if (-not ($PackageProvider))
{
    Write-Host -ForegroundColor Cyan 'Install-PackageProvider NuGet'
    Install-PackageProvider -Name NuGet -ForceBootstrap -IncludeDependencies
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
#	WindowsAutopilotIntune
#=================================================
$Module = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
if (-not $Module)
{
    Write-Host -ForegroundColor Cyan 'Install PowerShell Module WindowsAutopilotIntune'
    Install-Module WindowsAutopilotIntune -Force
}
#=================================================
#	AzureAD
#=================================================
$Module = Import-Module AzureAD -PassThru -ErrorAction Ignore
if (-not $Module)
{
    Write-Host -ForegroundColor Cyan 'Install PowerShell Module AzureAD'
    Install-Module AzureAD -Force
}
#=================================================
#	Get-WindowsAutoPilotInfo
#=================================================
Write-Host -ForegroundColor Cyan 'Install PowerShell Script Get-WindowsAutoPilotInfo'

#Install-Script -Name Get-WindowsAutoPilotInfo -Force
#=================================================
#	Complete
#=================================================
Write-Verbose 'Get-WindowsAutoPilotInfo is ready to run in a new PowerShell window' -Verbose
Start-Sleep -Seconds 5
#Start-Process PowerShell.exe
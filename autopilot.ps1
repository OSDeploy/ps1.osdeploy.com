'PSCloudScript for Autopilot Requirements'
'iex (irm autopilot.ps1.osdeploy.com)'

#=================================================
#   Block WinPE
#=================================================
if ($env:SystemDrive -eq 'X:')
{
    Write-Warning 'PSCloudScript cannot be run from WinPE'
    Start-Sleep -Seconds 5
    exit
}
#=================================================
#   Require OOBE
#=================================================
if ($env:UserName -ne 'defaultuser0')
{
    Write-Warning 'PSCloudScript must be run from OOBE'
    Start-Sleep -Seconds 5
    exit
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
#	NuGet
#=================================================
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
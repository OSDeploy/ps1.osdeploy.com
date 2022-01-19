<#
.SYNOPSIS
    AutopilotOOBE PSCloudScript at autopilotoobe.ps1.osdeploy.com
.DESCRIPTION
    A detailed description of the function or script. This keyword can be
    used only once in each topic.
.NOTES
    Requires Windows 10 1809+ - Windows 11
    In OOBE (Out-of-Box Experience), press Shift + F10 to open a Command Prompt
.LINK
    https://github.com/OSDeploy/ps1.osdeploy.com/blob/main/autopilotoobe.ps1
.EXAMPLE
    powershell iex(irm autopilotoobe.ps1.osdeploy.com)
#>
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
#	PackageManagement,PowerShellGet
#=================================================
if (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'}) {
    Write-Host -ForegroundColor Cyan 'PowerShellGet 2.2.5 or greater is installed'
}
else {
    Write-Host -ForegroundColor Cyan 'Install-Package PackageManagement,PowerShellGet'
    Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery

    Write-Host -ForegroundColor Cyan 'Import-Module PackageManagement,PowerShellGet'
    Import-Module PackageManagement,PowerShellGet -Force
}
#=================================================
#	Set-PSRepository PSGallery
#=================================================
$PSRepository = Get-PSRepository -Name PSGallery
if ($PSRepository)
{
    if ($PSRepository.InstallationPolicy -ne 'Trusted')
    {
        Write-Host -ForegroundColor Cyan 'Set-PSRepository PSGallery Trusted'
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
}
#=================================================
#	WindowsAutopilotIntune
#=================================================
$Requirement = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
if (-not $Requirement)
{
    Write-Host -ForegroundColor Cyan 'Install-Module AzureAD,Microsoft.Graph.Intune,WindowsAutopilotIntune'
    Install-Module WindowsAutopilotIntune -Force
}
#=================================================
#	AzureAD
#=================================================
$Requirement = Import-Module AzureAD -PassThru -ErrorAction Ignore
if (-not $Requirement)
{
    Write-Host -ForegroundColor Cyan 'Install-Module AzureAD'
    Install-Module AzureAD -Force -Verbose
}
#=================================================
#	Get-WindowsAutoPilotInfo
#=================================================
$Requirement = Get-InstalledScript -Name Get-WindowsAutoPilotInfod -ErrorAction SilentlyContinue
if (-not $Requirement)
{
    Write-Host -ForegroundColor Cyan 'Install-Script Get-WindowsAutoPilotInfo'
    Install-Script -Name Get-WindowsAutoPilotInfo -Force
}
#=================================================
#	AutopilotOOBE
#=================================================
Write-Host -ForegroundColor Cyan 'Install-Module AutopilotOOBE'
Install-Module AutopilotOOBE -Force
#=================================================
#	Complete
#=================================================
Write-Host -ForegroundColor Cyan 'Complete!'
Write-Verbose 'Starting a new PowerShell process for Start-AutopilotOOBE' -Verbose
Start-Sleep -Seconds 3
Start-Process PowerShell.exe -ArgumentList '-NoLogo'
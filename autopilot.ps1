'Autopilot Requirements PSCloudScript'
'autopilot.ps1.osdeploy.com'

'Requirements:'
'Windows 10 1809+'

'Environment:'
'OOBE (Out-of-Box Experience)'
'Press Shift + F10 to open a Command Prompt'

'Command Line (Command Prompt)'
'powershell iex(irm autopilot.ps1.osdeploy.com)'

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
#	PowerShellGet
#=================================================
if (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'}) {
    Write-Host -ForegroundColor Cyan 'PowerShellGet 2.2.5 or greater is installed'
}
else {
    Write-Host -ForegroundColor Cyan 'Install-Package PowerShellGet'
    Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery
    Import-Module PowerShellGet,PackageManagement -Force
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
Start-Process PowerShell.exe
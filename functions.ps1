function Set-oobeDisplay {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        Write-Host -ForegroundColor Yellow 'Verify the Display Resolution and Scale is set properly'
        Start-Process 'ms-settings:display' | Out-Null
        $ProcessId = (Get-Process -Name 'SystemSettings').Id
        if ($ProcessId) {
            Wait-Process $ProcessId
        }
    }
}
function Set-oobeRegionLanguage {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        Write-Host -ForegroundColor Yellow 'Verify the Language, Region, and Keyboard are set properly'
        Start-Process 'ms-settings:regionlanguage' | Out-Null
        $ProcessId = (Get-Process -Name 'SystemSettings').Id
        if ($ProcessId) {
            Wait-Process $ProcessId
        }
    }
}
function Set-oobeDateTime {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        Write-Host -ForegroundColor Yellow 'Verify the Date and Time is set properly including the Time Zone'
        Write-Host -ForegroundColor Yellow 'If this is not configured properly, Certificates and Domain Join may fail'
        Start-Process 'ms-settings:dateandtime' | Out-Null
        $ProcessId = (Get-Process -Name 'SystemSettings').Id
        if ($ProcessId) {
            Wait-Process $ProcessId
        }
    }
}
function Set-oobeExecutionPolicy {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        if ((Get-ExecutionPolicy) -ne 'RemoteSigned') {
            Write-Host -ForegroundColor Cyan 'Set-ExecutionPolicy RemoteSigned'
            Set-ExecutionPolicy RemoteSigned -Force
        }
    }
}
function Set-oobePackageManagement {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        if (Get-Module -Name PowerShellGet -ListAvailable | Where-Object {$_.Version -ge '2.2.5'}) {
            Write-Host -ForegroundColor Cyan 'PowerShellGet 2.2.5 or greater is installed'
        }
        else {
            Write-Host -ForegroundColor Cyan 'Install-Package PackageManagement,PowerShellGet'
            Install-Package -Name PowerShellGet -MinimumVersion 2.2.5 -Force -Confirm:$false -Source PSGallery | Out-Null
    
            Write-Host -ForegroundColor Cyan 'Import-Module PackageManagement,PowerShellGet'
            Import-Module PackageManagement,PowerShellGet -Force
        }
    }
}
function Set-oobeTrustPSGallery {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        $PSRepository = Get-PSRepository -Name PSGallery
        if ($PSRepository)
        {
            if ($PSRepository.InstallationPolicy -ne 'Trusted')
            {
                Write-Host -ForegroundColor Cyan 'Set-PSRepository PSGallery Trusted'
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
        }
    }
}
function Install-oobeModuleAutopilot {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        $Requirement = Import-Module WindowsAutopilotIntune -PassThru -ErrorAction Ignore
        if (-not $Requirement)
        {
            Write-Host -ForegroundColor Cyan 'Install-Module AzureAD,Microsoft.Graph.Intune,WindowsAutopilotIntune'
            Install-Module WindowsAutopilotIntune -Force
        }
    }
}
function Install-oobeModuleAzureAd {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        $Requirement = Import-Module AzureAD -PassThru -ErrorAction Ignore
        if (-not $Requirement)
        {
            Write-Host -ForegroundColor Cyan 'Install-Module AzureAD'
            Install-Module AzureAD -Force
        }
    }
}
function Install-oobeScriptAutopilot {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        $Requirement = Get-InstalledScript -Name Get-WindowsAutoPilotInfo -ErrorAction SilentlyContinue
        if (-not $Requirement)
        {
            Write-Host -ForegroundColor Cyan 'Install-Script Get-WindowsAutoPilotInfo'
            Install-Script -Name Get-WindowsAutoPilotInfo -Force
        }
    }
}
function Register-oobeAutopilotDevice {
    [CmdletBinding()]
    param (
        [System.String[]]
        $Command
    )

    if ($env:UserName -eq 'defaultuser0') {
        Write-Host -ForegroundColor Cyan 'Registering Device in Autopilot in new PowerShell window ' -NoNewline
        $AutopilotProcess = Start-Process PowerShell.exe -ArgumentList "-Command $AutopilotCommand" -PassThru
        Write-Host -ForegroundColor Green "(Process Id $($AutopilotProcess.Id))"
        Return $AutopilotProcess
    }
}
function Remove-oobeAppxPackage {
    [CmdletBinding()]
    param (
        [System.String[]]
        $Name
    )

    if ($env:UserName -eq 'defaultuser0') {
        Write-Host -ForegroundColor Cyan 'Removing Appx Packages'
        foreach ($Item in $Name) {
            if (Get-Command Get-AppxProvisionedPackage) {
                Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -Match $Item} | ForEach-Object {
                    Write-Host -ForegroundColor DarkGray $_.DisplayName
                    if ((Get-Command Remove-AppxProvisionedPackage).Parameters.ContainsKey('AllUsers')) {
                        Try
                        {
                            $null = Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_.PackageName
                        }
                        Catch
                        {
                            Write-Warning "AllUsers Appx Provisioned Package $($_.PackageName) did not remove successfully"
                        }
                    }
                    else {
                        Try
                        {
                            $null = Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName
                        }
                        Catch
                        {
                            Write-Warning "Appx Provisioned Package $($_.PackageName) did not remove successfully"
                        }
                    }
                }
            }
        }
    }
}
function Add-oobeCapability {
    [CmdletBinding()]
    param (
        [System.String[]]
        $Name
    )

    if ($env:UserName -eq 'defaultuser0') {
        $Requirement = Get-WindowsCapability -Online -Name "*$Name*" -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
        if ($Requirement) {
            Write-Host -ForegroundColor Cyan "Add-WindowsCapability"
            foreach ($Item in $Requirement) {
                Write-Host -ForegroundColor DarkGray $Item.DisplayName
                $Item | Add-WindowsCapability -Online | Out-Null
            }
        }
    }
}
function Add-oobeCapabilityNetFX {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        $Requirement = Get-WindowsCapability -Online -Name *NetFX3* -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Installed'}
        if ($Requirement) {
            Write-Host -ForegroundColor Cyan 'Add-WindowsCapability NetFX3'
            $Requirement | Add-WindowsCapability -Online | Out-Null
        }
    }
}
function Update-oobeDrivers {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        Write-Host -ForegroundColor Cyan 'Updating Windows Drivers in minimized window'
        if (!(Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore)) {
            try {
                Install-Module PSWindowsUpdate -Force
                Import-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate Driver Updates'
            }
        }
        if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
            Start-Process -WindowStyle Minimized PowerShell.exe -ArgumentList "-Command Install-WindowsUpdate -UpdateType Driver -AcceptAll -IgnoreReboot" -Wait
        }
    }
}
function Update-oobeWindows {
    [CmdletBinding()]
    param ()

    if ($env:UserName -eq 'defaultuser0') {
        Write-Host -ForegroundColor Cyan 'Updating Windows in minimized window'
        if (!(Get-Module PSWindowsUpdate -ListAvailable)) {
            try {
                Install-Module PSWindowsUpdate -Force
                Import-Module PSWindowsUpdate -Force
            }
            catch {
                Write-Warning 'Unable to install PSWindowsUpdate Windows Updates'
            }
        }
        if (Get-Module PSWindowsUpdate -ListAvailable -ErrorAction Ignore) {
            #Write-Host -ForegroundColor DarkCyan 'Add-WUServiceManager -MicrosoftUpdate -Confirm:$false'
            Add-WUServiceManager -MicrosoftUpdate -Confirm:$false | Out-Null
            #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot'
            #Install-WindowsUpdate -UpdateType Software -AcceptAll -IgnoreReboot -NotTitle 'Malicious'
            #Write-Host -ForegroundColor DarkCyan 'Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot'
            Start-Process -WindowStyle Minimized PowerShell.exe -ArgumentList "-Command Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -NotTitle 'Preview' -NotKBArticleID 'KB890830','KB5005463','KB4481252'" -Wait
        }
    }
}
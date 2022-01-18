'PSCloudScript to enable WinPE PSGallery and OSDCloud'
'iex (irm osdcloud.ps1.osdeploy.com)'

if ($env:SystemDrive -ne 'X:')
{
    Write-Warning 'This PSCloudScript must be run from WinPE'
    Start-Sleep -Seconds 5
}
else
{
    #=================================================
    #	Set-ExecutionPolicy
    #=================================================
    Write-Host -ForegroundColor Cyan 'Set Execution Policy'
    Set-ExecutionPolicy Bypass -Force
    #=================================================
    #	Set-WinPELocalAppData
    #=================================================
    if (Get-Item env:LOCALAPPDATA -ErrorAction Ignore)
    {
        Write-Verbose 'System Environment Variable LOCALAPPDATA is already present in this PowerShell session'
    }
    else
    {
        Write-Host -ForegroundColor Cyan 'Set LocalAppData Environment'
        Write-Verbose 'WinPE does not have the LOCALAPPDATA System Environment Variable'
        Write-Verbose 'This can be enabled for this Power Session, but it will not persist'
        Write-Verbose 'Set System Environment Variable LOCALAPPDATA for this PowerShell session'
        [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:UserProfile\AppData\Local")
    }
    #=================================================
    #	Set-WinPEPSProfile
    #=================================================
$PowerShellProfile = @'
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:UserProfile\AppData\Local")
'@
    if (-not (Test-Path "$env:UserProfile\Documents\WindowsPowerShell"))
    {
        $null = New-Item -Path "$env:UserProfile\Documents\WindowsPowerShell" -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    Write-Host -ForegroundColor Cyan 'Set LocalAppData in PowerShell Profile'
    Write-Verbose 'Set PowerShell Profile for this WinPE Session'
    $PowerShellProfile | Set-Content -Path "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force -Encoding Unicode
    #=================================================
    #	Install-WinPENuget
    #=================================================
    Write-Host -ForegroundColor Cyan 'Install Nuget'
    $NuGetBinaryProgramDataPath="$env:ProgramFiles\PackageManagement\ProviderAssemblies"
    $NuGetBinaryLocalAppDataPath="$env:LOCALAPPDATA\PackageManagement\ProviderAssemblies"
    $NuGetClientSourceURL = 'https://go.microsoft.com/fwlink/?LinkID=690216&clcid=0x409'
    $NuGetExeName = 'NuGet.exe'
    $NuGetExePath = $null
    $NuGetProvider = $null

    $PSGetProgramDataPath = Join-Path -Path $env:ProgramData -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
    $nugetExeBasePath = $PSGetProgramDataPath
    if (-not (Test-Path -Path $nugetExeBasePath))
    {
        $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
    $null = Invoke-WebRequest -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath

    $PSGetAppLocalPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
    $nugetExeBasePath = $PSGetAppLocalPath

    if (-not (Test-Path -Path $nugetExeBasePath))
    {
        $null = New-Item -Path $nugetExeBasePath -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    $nugetExeFilePath = Join-Path -Path $nugetExeBasePath -ChildPath $NuGetExeName
    $null = Invoke-WebRequest -Uri $NuGetClientSourceURL -OutFile $nugetExeFilePath
    #=================================================
    #	Install-WinPEPackageManagement
    #=================================================
    if (-not (Get-Module -Name PackageManagement))
    {
        Write-Host -ForegroundColor Cyan 'Install PackageManagement'
        $PackageManagementURL = "https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.7.nupkg"
        Invoke-WebRequest -UseBasicParsing -Uri $PackageManagementURL -OutFile "$env:TEMP\packagemanagement.1.4.7.zip"
        $Null = New-Item -Path "$env:TEMP\1.4.7" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\packagemanagement.1.4.7.zip" -DestinationPath "$env:TEMP\1.4.7"
        $Null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$env:TEMP\1.4.7" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement\1.4.7"
        Import-Module PackageManagement -Force
    }
    #=================================================
    #	Install-WinPEPowerShellGet
    #=================================================
    if (-not (Get-Module -Name PowerShellGet))
    {
        Write-Host -ForegroundColor Cyan 'Install PowerShellGet'
        $PowerShellGetURL = "https://psg-prod-eastus.azureedge.net/packages/powershellget.2.2.5.nupkg"
        Invoke-WebRequest -UseBasicParsing -Uri $PowerShellGetURL -OutFile "$env:TEMP\powershellget.2.2.5.zip"
        $Null = New-Item -Path "$env:TEMP\2.2.5" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\powershellget.2.2.5.zip" -DestinationPath "$env:TEMP\2.2.5"
        $Null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$env:TEMP\2.2.5" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet\2.2.5"
        Import-Module PowerShellGet -Force
    }
    #=================================================
    #	Set-WinPEPSGallery
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
    #	Install-WinPECurl
    #=================================================
    if (-not (Get-Command 'curl.exe' -ErrorAction SilentlyContinue))
    {
        Write-Host -ForegroundColor Cyan 'Install Curl'
        $Uri = 'https://curl.se/windows/dl-7.81.0/curl-7.81.0-win64-mingw.zip'
        Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile "$env:TEMP\curl.zip"

        $null = New-Item -Path "$env:TEMP\Curl" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\curl.zip" -DestinationPath "$env:TEMP\curl"

        Get-ChildItem "$env:TEMP\curl" -Include 'curl.exe' -Recurse | foreach {Copy-Item $_ -Destination "$env:SystemRoot\System32\curl.exe"}
    }
    #=================================================
    #	Complete
    #=================================================
    Write-Host -ForegroundColor Cyan 'Install OSD Module from PowerShell Gallery'
    Install-Module OSD -Force
    if (!(Get-Command 'curl.exe' -ErrorAction SilentlyContinue))
    {
        Write-Warning 'curl.exe is missing from WinPE. This is required for OSDCloud to function'
    }
    Write-Host -ForegroundColor Cyan "You are now ready to run 'powershell Start-OSDCloud' or 'powershell Start-OSDCloudGUI'"
}
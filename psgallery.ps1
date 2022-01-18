'PSCloudScript to enable WinPE PSGallery'
'iex (irm psgallery.ps1.osdeploy.com)'

function Set-WinPELocalAppData
{
    [CmdletBinding()]
    param()
    if (Get-Item env:LOCALAPPDATA -ErrorAction Ignore)
    {
        Write-Verbose 'System Environment Variable LOCALAPPDATA is already present in this PowerShell session'
    }
    else
    {
        Write-Verbose 'WinPE does not have the LOCALAPPDATA System Environment Variable'
        Write-Verbose 'This can be enabled for this Power Session, but it will not persist'
        Write-Verbose 'Set System Environment Variable LOCALAPPDATA for this PowerShell session'
        [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:UserProfile\AppData\Local")
    }
}
function Set-WinPEPSProfile
{
    [CmdletBinding()]
    param()

$PowerShellProfile = @'
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:UserProfile\AppData\Local")
'@
    if (-not (Test-Path "$env:UserProfile\Documents\WindowsPowerShell"))
    {
        $null = New-Item -Path "$env:UserProfile\Documents\WindowsPowerShell" -ItemType Directory -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    Write-Verbose 'Set PowerShell Profile for this WinPE Session'
    $PowerShellProfile | Set-Content -Path "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force -Encoding Unicode
}
function Install-WinPENuget
{
    [CmdletBinding()]
    param()
    
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
}
function Install-WinPEPackageManagement
{
    [CmdletBinding()]
    param()

    if (-not (Get-Module -Name PackageManagement))
    {
        $PackageManagementURL = "https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.7.nupkg"
        Invoke-WebRequest -UseBasicParsing -Uri $PackageManagementURL -OutFile "$env:TEMP\packagemanagement.1.4.7.zip"
        $Null = New-Item -Path "$env:TEMP\1.4.7" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\packagemanagement.1.4.7.zip" -DestinationPath "$env:TEMP\1.4.7"
        $Null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$env:TEMP\1.4.7" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement\1.4.7"
        Import-Module PackageManagement -Force
    }
}
function Install-WinPEPowerShellGet
{
    [CmdletBinding()]
    param()

    if (-not (Get-Module -Name PowerShellGet))
    {
        $PowerShellGetURL = "https://psg-prod-eastus.azureedge.net/packages/powershellget.2.2.5.nupkg"
        Invoke-WebRequest -UseBasicParsing -Uri $PowerShellGetURL -OutFile "$env:TEMP\powershellget.2.2.5.zip"
        $Null = New-Item -Path "$env:TEMP\2.2.5" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\powershellget.2.2.5.zip" -DestinationPath "$env:TEMP\2.2.5"
        $Null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$env:TEMP\2.2.5" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet\2.2.5"
        Import-Module PowerShellGet -Force
    }
}
function Set-WinPEPSGallery
{
    [CmdletBinding()]
    param()

    $PSRepository = Get-PSRepository -Name PSGallery

    if ($PSRepository)
    {
        if ($PSRepository.InstallationPolicy -ne 'Trusted')
        {
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }
    }
}
if ($env:SystemDrive -eq 'X:')
{
    Write-Host -ForegroundColor Cyan 'Set Execution Policy'
    Set-ExecutionPolicy Bypass -Force
    Write-Host -ForegroundColor Cyan 'Set LocalAppData Environment'
    Set-WinPELocalAppData
    Write-Host -ForegroundColor Cyan 'Set LocalAppData in PowerShell Profile'
    Set-WinPEPSProfile
    Write-Host -ForegroundColor Cyan 'Install Nuget'
    Install-WinPENuget
    Write-Host -ForegroundColor Cyan 'Install PackageManagement'
    Install-WinPEPackageManagement
    Write-Host -ForegroundColor Cyan 'Install PowerShellGet'
    Install-WinPEPowerShellGet
    Write-Host -ForegroundColor Cyan 'Trust PSGallery'
    Set-WinPEPSGallery
    Write-Host -ForegroundColor Cyan 'PowerShell Gallery should now work in WinPE'
}
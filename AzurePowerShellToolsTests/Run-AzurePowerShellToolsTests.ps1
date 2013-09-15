[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)]
    [String] $azureConnectionString,

    [Parameter(Mandatory=$false)]
    [Switch] $release
)

if ($PSVersionTable -eq $null -or $PSVersionTable['PSVersion'].Major -ne 3) {
    throw 'Powershell 3.0 is expected.'
}

$script_path = split-path -parent $MyInvocation.MyCommand.Definition
cd $script_path

# By default, PSTest is automatically loaded from within the Visual Studio
# Package Manager Console. We also need to cover the case when this script
# is run outside of Visual Studio
$gm = Get-Module | Select Name | Select-String -Pattern 'PSTest'

if ($gm -eq $null) {
    Write-Verbose 'PSTest module is not imported. Searching for pstest.dll...'

    $pstest_path = [System.IO.Path]::GetTempPath()

    $pstest_path = [System.IO.Path]::Combine($pstest_path, 'PSTest')

    $pstest_file = Get-ChildItem "$pstest_path" -Filter pstest.dll -Recurse | Sort -Descending -Property LastWriteTime | Select -First 1 -ExpandProperty FullName

    if ($pstest_file -eq $null) {
        throw "File 'pstest.dll' could not be found."
    }

    Import-Module "$pstest_file" -ErrorAction Stop
}

# Do the same for the NUnit module... This one is a little more
# straight-forward since we have the folder in our project folder
$gm = Get-Module | Select Name | Select-String -Pattern 'NUnit'

if ($gm -eq $null) {
    Write-Verbose 'NUnit module is not imported. Attempting to import...'

    Import-Module .\NUnit\NUnit -ErrorAction Stop
}

# Check to see if our project helper module is currently loaded and, if so,
# unload it so we can load the latest version later
$gm = Get-Module | Select Name | Select-String -Pattern 'AzurePowerShellToolsTests'

if ($gm -ne $null) {
    Write-Verbose 'AzurePowerShellToolsTests module is currently loaded. Attempting to remove...'

    Remove-Module AzurePowerShellToolsTests -ErrorAction Stop
}

# Check to see if our project module is currently loaded and, if so,
# unload it so we can load the latest version later
$gm = Get-Module | Select Name | Select-String -Pattern 'AzurePowerShellTools'

if ($gm -ne $null) {
    Write-Verbose 'AzurePowerShellTools module is currently loaded. Attempting to remove...'

    Remove-Module AzurePowerShellTools -ErrorAction Stop
}

# Clear out any existing configuration...
$fmt = '{0,-' + (($Host.UI.RawUI.BufferSize | Select -ExpandProperty Width) - 1) + '}'
Write-Host ($fmt -f 'W A R N I N G') -BackgroundColor Yellow -ForegroundColor Black

$warning = "These tests will clear out any configuration information " +
           "you may already have set-up. These tests will back-up your " +
           "configuration file to .\.config.json and will also attempt " +
           "to restore your settings when completed."

Write-Warning "$warning"

$yes = ('Y','y','')
$no = ('N','n')
$valid = $yes + $no
do {
    $response = Read-Host -Prompt "Continue? [Y/n]"
}
until ($valid -contains $response)

if ($yes -contains $response) {
    Import-Module .\AzurePowerShellToolsTests.psm1 -ErrorAction Stop

    if ($release) {
        Import-Module .\bin\Release\AzurePowerShellTools.dll -ErrorAction Stop
    } else {
        Import-Module .\bin\Debug\AzurePowerShellTools.dll -ErrorAction Stop
    }

    # if $azureConnectionString is empty, only run a subset of tests
    if (![String]::IsNullOrEmpty($azureConnectionString)) {
        # validate the $azureConnectionString parameter
        # NOTE: this is a bit weird since we have a unit test for it
        # later... we want to use it to validate this argument and we
        # need to ensure it works correctly...
        $valid = Test-AzureStorageConfiguration -AzureConnectionString "$azureConnectionString"

        if (!$valid) {
            throw 'Invalid AzureConnectionString argument.'
        }
    }

    Write-Verbose 'Backing up config file...'
    Backup-AzureStorageConfigurationFiles

    .\GetAzureStorageConfigurationTests.ps1
    .\SetAzureStorageConfigurationTests.ps1
    .\TestAzureStorageConfigurationTests.ps1

    if (![String]::IsNullOrEmpty($azureConnectionString)) {
        .\AzureQueueTests.ps1
    } else {
        Write-HostHeading 'Tests requiring access to Azure have not been run because a connnection string has not been specified.' -BackgroundColor Yellow -ForegroundColor Black -BreakBefore
    }

    Write-Verbose 'Restoring config file...'
    Restore-AzureStorageConfigurationFiles

    Write-HostHeading 'Your Azure Storage Configuration settings are:' -BackgroundColor Blue -ForegroundColor White -BreakBefore
    Get-AzureStorageConfiguration
}

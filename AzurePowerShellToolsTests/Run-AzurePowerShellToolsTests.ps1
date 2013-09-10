[CmdletBinding()]
Param()

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
        $message = "File 'pstest.dll' could not be found."
        $exception = New-Object System.IO.FileNotFoundException $message
        $errorID = 'FileNotFound'
        $errorCategory = [Management.Automation.ErrorCategory]::ObjectNotFound
        $target = $pstest_file
        $errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID,
            $errorCategory, $target
        $PSCmdlet.ThrowTerminatingError($errorRecord)
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

    Write-Verbose 'Backing up config file...'
    Backup-AzureStorageConfigurationFiles

    Import-Module .\bin\Debug\AzurePowerShellTools.dll -ErrorAction Stop

    .\GetAzureStorageConfigurationTests.ps1
    .\SetAzureStorageConfigurationTests.ps1

    Write-Verbose 'Restoring config file...'
    Restore-AzureStorageConfigurationFiles

    $fmt = '{0,-' + (($Host.UI.RawUI.BufferSize | Select -ExpandProperty Width) - 1) + '}'
    Write-Host ($fmt -f 'Your Azure Storage Configuration settings are:') -BackgroundColor Blue -ForegroundColor White
    Get-AzureStorageConfiguration
}

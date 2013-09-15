
if ($PSVersionTable -eq $null -or $PSVersionTable['PSVersion'].Major -ne 3) {
    throw 'Powershell 3.0 is expected.'
}

$script_path = split-path -parent $MyInvocation.MyCommand.Definition
cd $script_path

# Check to see if our project helper module is currently loaded and, if so,
# unload it so we can load the latest version later
$gm = Get-Module | Select -ExpandProperty Name | Select-String -Pattern '^AzurePowerShellTools$'

if ($gm -ne $null) {
    Write-Warning 'AzurePowerShellTools module is currently loaded. Attempting to remove...'
    
    Write-Warning 'Note, this will not release the AzurePowerShellTools.dll; Visual Studio will not be able to build your solution until you close and re-open a PowerShell instance.'

    Remove-Module AzurePowerShellTools -ErrorAction Stop
}


Import-Module .\bin\Debug\AzurePowerShellTools.dll
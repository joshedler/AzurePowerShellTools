function Get-RandomString {
    param (
        [int]$Length
    )
    
    $set    = 'abcdefghijklmnopqrstuvwxyz0123456789'.ToCharArray()
    $result = ''
    for ($x = 0; $x -lt $Length; $x++) {
        $result += $set | Get-Random
    }
    
    return $result
}

function Write-HostHeading {
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [String] $Message,
        [String] $BackgroundColor,
        [String] $ForegroundColor,
        [Switch] $BreakBefore,
        [Switch] $BreakAfter
    )

    if ([String]::IsNullOrEmpty($BackgroundColor)) {
        $BackgroundColor = 'White'
    }

    if ([String]::IsNullOrEmpty($ForegroundColor)) {
        $ForegroundColor = 'Black'
    }

    if ($BreakBefore) { Write-Host '' }

    $fmt = '{0,-' + (($Host.UI.RawUI.BufferSize | Select -ExpandProperty Width) - 1) + '}'
    Write-Host ($fmt -f $Message) -BackgroundColor $BackgroundColor -ForegroundColor $ForegroundColor

    if ($BreakAfter) { Write-Host '' }
}

function Get-RandomizedAzureStorageConfigurationString {
    # valid strings are in the form:
    # @"^DefaultEndpointsProtocol=(http|https);AccountName=(.+);AccountKey=(.+)$"
    #
    # Storage account names must be between 3 and 24 characters in length and use 
    # numbers and lower-case letters only.

    $proto = @( 'http', 'https' ) | Get-Random
    $name = 'apstteststorage' + (Get-RandomString 8)
    $key = Get-RandomString 90

    return "DefaultEndpointsProtocol=$proto;AccountName=$name;AccountKey=$key"
}

function Get-AzureStorageConfigurationFileInformation {
    $config_path = [System.IO.Path]::Combine($env:APPDATA, 'AzurePowerShellTools')
    $config_file = [System.IO.Path]::Combine($config_path, 'config.json')
    $bak_file = [System.IO.Path]::Combine($script_path, '.config.json')

    return @( $config_path, $config_file, $bak_file )
}

function Backup-AzureStorageConfigurationFiles {
    $config_path, $config_file, $bak_file = Get-AzureStorageConfigurationFileInformation

    Copy-Item "$config_file" "$bak_file"
}

function Remove-AzureStorageConfigurationFiles {
    $config_path, $config_file, $bak_file = Get-AzureStorageConfigurationFileInformation

    Remove-Item "$config_file" -ErrorAction Ignore
    Remove-Item "$config_path" -ErrorAction Ignore
}

function Restore-AzureStorageConfigurationFiles {
    $config_path, $config_file, $bak_file = Get-AzureStorageConfigurationFileInformation

    New-Item "$config_path" -ItemType Directory -ErrorAction Ignore | Out-Null
    Copy-Item "$bak_file" "$config_file"
}
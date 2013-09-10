################################################################################
#                                                                              #
# C O M M O N   T E S T   S C R I P T   H E A D E R                            #
#                                                                              #
# There's a lot of set-up done from AzurePowerShellToolsTests.ps1
# that we don't want to skip...
if ([string]::IsNullOrEmpty($MyInvocation.ScriptName)) {
    throw 'This script is expecting to be run from AzurePowerShellToolsTests.ps1'
}

$fmt = '{0,-' + (($Host.UI.RawUI.BufferSize | Select -ExpandProperty Width) - 1) + '}'
Write-Host ($fmt -f "$($MyInvocation.MyCommand)") -BackgroundColor DarkMagenta -ForegroundColor White
#                                                                              #
#                                                                              #
################################################################################

(New-Test 'config file is missing' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $config_path, $config_file, $bak_file = Get-AzureStorageConfigurationFileInformation

    # act/assert
    $Assert::False([System.IO.File]::Exists("$config_file"))
}),

(New-Test 'config folder is missing' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $config_path, $config_file, $bak_file = Get-AzureStorageConfigurationFileInformation

    # act/assert
    $Assert::False([System.IO.Directory]::Exists("$config_path"))
}),

(New-Test 'creates the config folder' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $config_path, $config_file, $bak_file = Get-AzureStorageConfigurationFileInformation

    # act
    Get-AzureStorageConfiguration

    # assert
    $Assert::True([System.IO.Directory]::Exists("$config_path"))
}),

(New-Test 'creates the config file' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $config_path, $config_file, $bak_file = Get-AzureStorageConfigurationFileInformation

    # act
    Get-AzureStorageConfiguration

    # assert
    $Assert::True([System.IO.File]::Exists("$config_file"))
}),

(New-Test 'AzureConnectionString default value' {
    # arrange
    Remove-AzureStorageConfigurationFiles

    # act
    $actual = Get-AzureStorageConfiguration | Select -ExpandProperty AzureConnectionString

    # assert
    $Assert::That($actual, $Is::Empty)
}),
    
(New-Test 'TimeoutInSeconds default value' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    
    # act
    $actual = Get-AzureStorageConfiguration | Select -ExpandProperty TimeoutInSeconds

    # assert
    $Assert::That($actual, $Is::EqualTo(1800))
}),
    
(New-Test 'RetryCount default value' {
    # arrange
    Remove-AzureStorageConfigurationFiles

    # act
    $actual = Get-AzureStorageConfiguration | Select -ExpandProperty RetryCount

    # assert
    $Assert::That($actual, $Is::EqualTo(3))
}) |

Invoke-Test | 
    
Format-TestResult -All

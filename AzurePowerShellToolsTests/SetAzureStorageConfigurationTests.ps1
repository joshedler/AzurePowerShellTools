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

(New-Test 'fails with no arguments' {
    # arrange
    Remove-AzureStorageConfigurationFiles

    # act & assert
    Try {
        Set-AzureStorageConfiguration
        $Assert::Fail('Expected exception did not occur.')
    }
    Catch [System.Management.Automation.ParameterBindingException] {
        # exception expected; nothing to do
    }
}),

(New-Test 'fails with inconsistent arguments' {
    # arrange
    Remove-AzureStorageConfigurationFiles

    # act & assert
    Try {
        Set-AzureStorageConfiguration -AzureConnectionString 'Why?' -ClearAzureConnectionString
        $Assert::Fail('Expected exception did not occur.')
    }
    Catch [System.Management.Automation.ParameterBindingException] {
        # exception expected; nothing to do
    }
}),

(New-Test 'fails when AzureConnectionString is invalid (multiple)' {
    # outer arrange
    $tests = @{
        'invalid pattern' = 'Why?';
        'invalid character "_"' = 'DefaultEndpointsProtocol=https;AccountName=abc_123;AccountKey=xxxYYYzzz';
        'invalid character "-"' = 'DefaultEndpointsProtocol=https;AccountName=abc-123;AccountKey=xxxYYYzzz';
        'invalid character " "' = 'DefaultEndpointsProtocol=https;AccountName=abc 123;AccountKey=xxxYYYzzz';
        'invalid character "."' = 'DefaultEndpointsProtocol=https;AccountName=abc.123;AccountKey=xxxYYYzzz';
        'too few characters' = 'DefaultEndpointsProtocol=https;AccountName=ab;AccountKey=xxxYYYzzz';
        'too many characters' = 'DefaultEndpointsProtocol=https;AccountName=abcdefghijklmnopqrstuvwxy;AccountKey=xxxYYYzzz';
    }

    $tests.GetEnumerator() | Foreach-Object {
        # arrange
        Remove-AzureStorageConfigurationFiles

        $name = $_.key
        $pattern = $_.value

        # act & assert
        Try {
            Set-AzureStorageConfiguration -AzureConnectionString "$pattern"
            $Assert::Fail("Expected exception for test [$name] did not occur.")
        }
        Catch [AzurePowerShellTools.InvalidAzureConnectionStringPatternException] {
            # exception expected; nothing to do
        }
    }
}),

(New-Test 'fails with TimeoutInSeconds < 1' {
    # arrange
    Remove-AzureStorageConfigurationFiles

    # act & assert
    Try {
        Set-AzureStorageConfiguration -TimeoutInSeconds 0
        $Assert::Fail('Expected exception did not occur.')
    }
    Catch [System.Management.Automation.ParameterBindingException] {
        # exception expected; nothing to do
    }
}),

(New-Test 'fails with TimeoutInSeconds > 3600' {
    # arrange
    Remove-AzureStorageConfigurationFiles

    # act & assert
    Try {
        Set-AzureStorageConfiguration -TimeoutInSeconds 3601
        $Assert::Fail('Expected exception did not occur.')
    }
    Catch [System.Management.Automation.ParameterBindingException] {
        # exception expected; nothing to do
    }
}),

(New-Test 'fails with RetryCount < 1' {
    # arrange
    Remove-AzureStorageConfigurationFiles

    # act & assert
    Try {
        Set-AzureStorageConfiguration -RetryCount 0
        $Assert::Fail('Expected exception did not occur.')
    }
    Catch [System.Management.Automation.ParameterBindingException] {
        # exception expected; nothing to do
    }
}),

(New-Test 'fails with RetryCount > 5' {
    # arrange
    Remove-AzureStorageConfigurationFiles

    # act & assert
    Try {
        Set-AzureStorageConfiguration -RetryCount 6
        $Assert::Fail('Expected exception did not occur.')
    }
    Catch [System.Management.Automation.ParameterBindingException] {
        # exception expected; nothing to do
    }
}),

(New-Test 'succeeds with valid AzureConnectionString and no prior configuration' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $expected = Get-RandomizedAzureStorageConfigurationString

    # act
    $actual = Set-AzureStorageConfiguration -AzureConnectionString "$expected" | Select -ExpandProperty AzureConnectionString

    # assert
    $Assert::That($actual, $Is::EqualTo($expected))
}),

(New-Test 'succeeds with valid AzureConnectionString and overwrites prior configuration' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $start = Get-RandomizedAzureStorageConfigurationString
    $expected = Get-RandomizedAzureStorageConfigurationString

    # act
    Set-AzureStorageConfiguration -AzureConnectionString "$start"
    $actual = Set-AzureStorageConfiguration -AzureConnectionString "$expected" | Select -ExpandProperty AzureConnectionString

    # assert
    $Assert::That($actual, $Is::EqualTo($expected))
}),

(New-Test 'succeeds with valid RetryCount and no prior configuration' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $expected = 5

    # act
    $actual = Set-AzureStorageConfiguration -RetryCount $expected | Select -ExpandProperty RetryCount

    # assert
    $Assert::That($actual, $Is::EqualTo($expected))
}),

(New-Test 'succeeds with valid RetryCount and overwrites prior configuration' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $start = 5
    $expected = 1

    # act
    Set-AzureStorageConfiguration -RetryCount $start
    $actual = Set-AzureStorageConfiguration -RetryCount $expected | Select -ExpandProperty RetryCount

    # assert
    $Assert::That($actual, $Is::EqualTo($expected))
}),

(New-Test 'succeeds with valid TimeoutInSeconds and no prior configuration' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $expected = 2000

    # act
    $actual = Set-AzureStorageConfiguration -TimeoutInSeconds $expected | Select -ExpandProperty TimeoutInSeconds

    # assert
    $Assert::That($actual, $Is::EqualTo($expected))
}),

(New-Test 'succeeds with valid TimeoutInSeconds and overwrites prior configuration' {
    # arrange
    Remove-AzureStorageConfigurationFiles
    $start = 2000
    $expected = 999

    # act
    Set-AzureStorageConfiguration -TimeoutInSeconds $start
    $actual = Set-AzureStorageConfiguration -TimeoutInSeconds $expected | Select -ExpandProperty TimeoutInSeconds

    # assert
    $Assert::That($actual, $Is::EqualTo($expected))
}) |

Invoke-Test | 
    
Format-TestResult -All

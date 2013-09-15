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

(New-Test 'returns false when AzureConnectionString is invalid (multiple)' {
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

        $name = $_.key
        $pattern = $_.value

        # act
        $result = Test-AzureStorageConfiguration -AzureConnectionString "$pattern"

        # assert
        if ($result -ne $false) {
            $Assert::Fail("Expected false result for test [$name].")
        }
    }
}),

(New-Test 'returns true with valid AzureConnectionString' {
    # arrange
    $conn = Get-RandomizedAzureStorageConfigurationString

    # act
    $result = Test-AzureStorageConfiguration -AzureConnectionString "$conn"

    # assert
    $Assert::True($result)
}) |

Invoke-Test | 
    
Format-TestResult -All

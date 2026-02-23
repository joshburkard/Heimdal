# ============================================================================
# Test Declarations - Structured Approach
# ============================================================================
# Copy this file to 'declarations.ps1' and fill in your actual test values
# The 'declarations.ps1' file should be added to .gitignore to avoid committing sensitive data

#region Global Connection Settings
# Heimdal API Connection

$HeimdalApiUrl     = "https://dashboard.heimdalsecurity.com/api/heimdalapi"  # Base URL for Heimdal API
$HeimdalCustomerId = '123456'
$HeimdalApiKey     = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'


# this array is used by the test framework to automatically redact sensitive values from test output and logs
$SensitiveValues = @(
    $HeimdalApiKey,
    $HeimdalCustomerId
)

#endregion

#region Test Execution Control
# Set to $true to run all functional tests during build
# Set to $false (default) to only run tests for functions that changed since last git commit
# This prevents accidentally triggering script executions or other actions in Heimdal during routine builds
$script:RunAllFunctionalTests = $false

# Timeout Settings
$script:TestTimeout = 300  # Timeout in seconds for script execution tests
$script:TestPollingInterval = 5  # Polling interval in seconds for status checks
#endregion


$script:TestData = @{
    # ========================================================================
    # Connect-Heimdal
    # ========================================================================
    'Connect-Heimdal' = @{
        Valid = @{
            ApiURL = $HeimdalApiUrl
            CustomerID = $HeimdalCustomerId
            ApiKey = $HeimdalApiKey
        }
        Invalid = @{
            ApiURL = $HeimdalApiUrl
            CustomerID = 'WrongCustomerID'
            ApiKey = 'WrongApiKey'
        }
    }

    # ========================================================================
    # Get-HeimdalDevice
    # ========================================================================
    'Get-HeimdalDevice' = @{
        ByName = @{
            Name = "TestDeviceName"
        }
        ByWrongName = @{
            Name = "NonExistentDeviceName"
        }
        ByDate = @{
            StartDate = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddT00:00:00")
            EndDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        }
    }
}
#endregion

#region Helper Functions for Tests
# Helper function to get test data for a specific function and parameter set
function Get-TestData {
    param(
        [string]$FunctionName,
        [string]$ParameterSet
    )

    if ($script:TestData.ContainsKey($FunctionName)) {
        if ($script:TestData[$FunctionName].ContainsKey($ParameterSet)) {
            return $script:TestData[$FunctionName][$ParameterSet]
        }
    }
    return $null
}

# Helper function to check if test data exists for a function
function Test-HasTestData {
    param(
        [string]$FunctionName,
        [string]$ParameterSet = $null
    )

    if ($script:TestData.ContainsKey($FunctionName)) {
        if ($null -eq $ParameterSet) {
            return $true
        }
        return $script:TestData[$FunctionName].ContainsKey($ParameterSet)
    }
    return $false
}
#endregion


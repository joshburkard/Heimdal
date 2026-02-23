# Functional Tests for Connect-Heimdal
# Tests the Connect-Heimdal function behavior and return values

BeforeAll {
    # Load test declarations
    . (Join-Path $PSScriptRoot "declarations.ps1")

    # Load all functions
    $CodePath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Code"
    Get-ChildItem -Path (Join-Path $CodePath "Private") -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    Get-ChildItem -Path (Join-Path $CodePath "Public") -Filter "*.ps1" | ForEach-Object { . $_.FullName }

    # Get test data for this function
    $script:TestConnectData = $script:TestData['Connect-Heimdal']
}

Describe "Connect-Heimdal Function Tests" -Tag "Integration", "Connection" {

    Context "Test Data Validation" {

        It "Should have test data defined in declarations.ps1" {
            # Assert
            $script:TestConnectData | Should -Not -BeNullOrEmpty
            $script:TestData.ContainsKey('Connect-Heimdal') | Should -Be $true
        }

        It "Should have required test data parameter sets" {
            # Assert
            $script:TestConnectData.ContainsKey('Valid') | Should -Be $true
            $script:TestConnectData.ContainsKey('Invalid') | Should -Be $true
        }

        It "Should output test data for verification" {
            # Output test data
            Write-Host "`n=== Test Data for Connect-Heimdal ===" -ForegroundColor Cyan
            Write-Host "Valid:" -ForegroundColor Yellow
            Write-Host "  ApiURL: $($script:TestConnectData.Valid.ApiURL)" -ForegroundColor White
            Write-Host "  CustomerID: $($script:TestConnectData.Valid.CustomerID)" -ForegroundColor White
            Write-Host "  ApiKey: $(if($script:TestConnectData.Valid.ApiKey){'Configured'}else{'Not Configured'})" -ForegroundColor White

            Write-Host "Invalid:" -ForegroundColor Yellow
            Write-Host "  ApiURL: $($script:TestConnectData.Invalid.ApiURL)" -ForegroundColor White
            Write-Host "  CustomerID: $($script:TestConnectData.Invalid.CustomerID)" -ForegroundColor White
            Write-Host "  ApiKey: $(if($script:TestConnectData.Invalid.ApiKey){'Configured'}else{'Not Configured'})" -ForegroundColor White
            Write-Host "============================================================`n" -ForegroundColor Cyan

            # This test always passes, it's just for output
            $true | Should -Be $true
        }
    }

    Context "Connection Establishment" {

        It "Should connect successfully with valid server" {
            # Arrange
            $params = $script:TestConnectData.Valid

            # Act & Assert
            { Connect-Heimdal @params } | Should -Not -Throw
        }

        It "Should store connection details in script variables" {
            # Arrange & Act
            Connect-Heimdal -ApiURL $script:TestConnectData.Valid.ApiURL -CustomerID $script:TestConnectData.Valid.CustomerID -ApiKey $script:TestConnectData.Valid.ApiKey

            # Assert
            $script:HDSession.ApiURL | Should -Be $script:TestConnectData.Valid.ApiURL
            $script:HDSession.CustomerID | Should -Be $script:TestConnectData.Valid.CustomerID
            $script:HDSession.ApiKey | Should -Be $script:TestConnectData.Valid.ApiKey
        }

        It "Should return connection information object" {
            # Arrange & Act
            $result = Connect-Heimdal -ApiURL $script:TestConnectData.Valid.ApiURL -CustomerID $script:TestConnectData.Valid.CustomerID -ApiKey $script:TestConnectData.Valid.ApiKey

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.ApiURL | Should -Be $script:TestConnectData.Valid.ApiURL
            $result.CustomerID | Should -Be $script:TestConnectData.Valid.CustomerID
            $result.ApiKey | Should -Be $script:TestConnectData.Valid.ApiKey
        }

        It "Should fail with invalid credentials" {
            # Arrange
            $params = @{
                ApiURL = $script:TestConnectData.Invalid.ApiURL
                CustomerID = $script:TestConnectData.Invalid.CustomerID
                ApiKey = $script:TestConnectData.Invalid.ApiKey
            }

            # Act & Assert
            { Connect-Heimdal @params -ErrorAction Stop } | Should -Throw
        }

        It "Should fail with invalid server" {
            # Arrange
            $invalidServer = "invalid-server-name-that-does-not-exist.local"

            # Act & Assert
            { Connect-Heimdal -ApiURL $invalidServer -CustomerID $script:TestConnectData.Valid.CustomerID -ApiKey $script:TestConnectData.Valid.ApiKey -ErrorAction Stop } | Should -Throw
        }
    }
}
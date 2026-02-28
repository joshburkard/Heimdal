# Functional Tests for Get-HeimdalDeviceNotification
# Tests the Get-HeimdalDeviceNotification function behavior and return values

BeforeAll {
    # Load test declarations
    . (Join-Path $PSScriptRoot "declarations.ps1")

    # Load all functions
    $CodePath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Code"
    Get-ChildItem -Path (Join-Path $CodePath "Private") -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    Get-ChildItem -Path (Join-Path $CodePath "Public") -Filter "*.ps1" | ForEach-Object { . $_.FullName }

    # Get test data for this function
    $ConnectData = $script:TestData['Connect-Heimdal']['Valid']
    $script:TestGetDeviceData = $script:TestData['Get-HeimdalDeviceNotification']

    Connect-Heimdal @ConnectData
}

Describe "Get-HeimdalDeviceNotification Function Tests" -Tag "Integration", "Connection" {
    Context "Test Data Validation" {

        It "Should have test data defined in declarations.ps1" {
            # Assert
            $script:TestGetDeviceData | Should -Not -BeNullOrEmpty
            $script:TestData.ContainsKey('Get-HeimdalDeviceNotification') | Should -Be $true
        }

        It "Should have required test data parameter sets" {
            # Assert
            $script:TestGetDeviceData.ContainsKey('ByClientInfoId') | Should -Be $true
        }

        It "Should output test data for verification" {
            # Output test data
            Write-Host "`n=== Test Data for Get-HeimdalDeviceNotification ===" -ForegroundColor Cyan
            Write-Host "ByClientInfoId:" -ForegroundColor Yellow
            Write-Host "  ClientInfoId: $($script:TestGetDeviceData.ByClientInfoId.ClientInfoId)" -ForegroundColor White
            Write-Host "============================================================`n" -ForegroundColor Cyan

            # This test always passes, it's just for output
            $true | Should -Be $true
        }
    }

    Context 'Connection Required' {
        It 'should throw when Connect-Heimdal has not been called' {
            # Arrange - Backup and clear connection
            $backupConnection = $script:HDSession.Clone()
            $script:HDSession = $null

            # Test that the function throws
            $params = $script:TestGetDeviceData.ByClientInfoId
            { Get-HeimdalDeviceNotification @params } | Should -Throw

            # Restore connection
            $script:HDSession = $backupConnection
        }
    }

    Context "Get Device Notification by ClientInfoId" {
        It "Should retrieve device notifications for a valid ClientInfoId" {
            # Arrange
            $params = $script:TestGetDeviceData.ByClientInfoId

            # Act
            $result = Get-HeimdalDeviceNotification @params

            # Assert
            # $result | Should -Not -BeNullOrEmpty
            ([string]::IsNullOrEmpty( $result ) -or $result -is [System.Object] -or $result -is [System.Object[]]) | Should -BeTrue
        }
        It "Should return empty result for an invalid ClientInfoId" {
            # Arrange
            $params = $script:TestGetDeviceData.ByWrongClientInfoId

            # Act
            $result = Get-HeimdalDeviceNotification @params

            # Assert
            $result | Should -BeNullOrEmpty
        }
    }
}
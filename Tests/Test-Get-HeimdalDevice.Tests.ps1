# Functional Tests for Get-HeimdalDevice
# Tests the Get-HeimdalDevice function behavior and return values

BeforeAll {
    # Load test declarations
    . (Join-Path $PSScriptRoot "declarations.ps1")

    # Load all functions
    $CodePath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Code"
    Get-ChildItem -Path (Join-Path $CodePath "Private") -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    Get-ChildItem -Path (Join-Path $CodePath "Public") -Filter "*.ps1" | ForEach-Object { . $_.FullName }

    # Get test data for this function
    $ConnectData = $script:TestData['Connect-Heimdal']['Valid']
    $script:TestGetDeviceData = $script:TestData['Get-HeimdalDevice']

    Connect-Heimdal @ConnectData
}

Describe "Get-HeimdalDevice Function Tests" -Tag "Integration", "Connection" {
    Context "Test Data Validation" {

        It "Should have test data defined in declarations.ps1" {
            # Assert
            $script:TestGetDeviceData | Should -Not -BeNullOrEmpty
            $script:TestData.ContainsKey('Get-HeimdalDevice') | Should -Be $true
        }

        It "Should have required test data parameter sets" {
            # Assert
            $script:TestGetDeviceData.ContainsKey('ByName') | Should -Be $true
            $script:TestGetDeviceData.ContainsKey('ByWrongName') | Should -Be $true
            $script:TestGetDeviceData.ContainsKey('ByDate') | Should -Be $true
            $script:TestGetDeviceData.ContainsKey('ByAllPage') | Should -Be $true
            $script:TestGetDeviceData.ContainsKey('ByPageSize') | Should -Be $true
        }

        It "Should output test data for verification" {
            # Output test data
            Write-Host "`n=== Test Data for Get-HeimdalDevice ===" -ForegroundColor Cyan
            Write-Host "ByName:" -ForegroundColor Yellow
            Write-Host "  Name: $($script:TestGetDeviceData.ByName.Name)" -ForegroundColor White
            Write-Host "ByWrongName:" -ForegroundColor Yellow
            Write-Host "  Name: $($script:TestGetDeviceData.ByWrongName.Name)" -ForegroundColor White
            Write-Host "ByDate:" -ForegroundColor Yellow
            Write-Host "  StartDate: $($script:TestGetDeviceData.ByDate.StartDate)" -ForegroundColor White
            Write-Host "  EndDate: $($script:TestGetDeviceData.ByDate.EndDate)" -ForegroundColor White
            Write-Host "ByAllPage:" -ForegroundColor Yellow
            Write-Host "  GetAllPages: $($script:TestGetDeviceData.ByAllPage.GetAllPages)" -ForegroundColor White
            Write-Host "ByPageSize:" -ForegroundColor Yellow
            Write-Host "  pageSize: $($script:TestGetDeviceData.ByPageSize.pageSize)" -ForegroundColor White
            Write-Host "  pageNumber: $($script:TestGetDeviceData.ByPageSize.pageNumber)" -ForegroundColor White
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
            { Get-HeimdalDevice } | Should -Throw

            # Restore connection
            $script:HDSession = $backupConnection
        }
    }

    Context "Get-HeimdalDevice Functionality" {

        It "Should retrieve device by name successfully" {
            # Arrange
            $params = $script:TestGetDeviceData.ByName

            # Act
            $result = Get-HeimdalDevice @params

            # Assert
            $result | Should -Not -BeNullOrEmpty
            ($result | Where-Object { $_.hostname -eq $params.Name }) | Should -Not -BeNullOrEmpty
        }

        It "Should return empty result for non-existent device name" {
            # Arrange
            $params = $script:TestGetDeviceData.ByWrongName

            # Act
            $result = Get-HeimdalDevice @params

            # Assert
            $result | Should -BeNullOrEmpty
        }

        It "Should retrieve device by clientInfoId successfully" {
            # Arrange
            $params = $script:TestGetDeviceData.ByClientInfoId

            # Act
            $result = Get-HeimdalDevice @params

            # Assert
            $result | Should -Not -BeNullOrEmpty
            ($result | Where-Object { $_.id -eq $params.ClientInfoId }) | Should -Not -BeNullOrEmpty
        }

        It "Should retrieve devices within date range successfully" {
            # Arrange
            $params = $script:TestGetDeviceData.ByDate
            $StartDate = $params.StartDate
            $EndDate = $params.EndDate

            # Act
            $result = Get-HeimdalDevice @params

            # Assert
            $result | Should -Not -BeNullOrEmpty

            write-Host "Verifying that all retrieved devices have lastSeen within the specified date range..." -ForegroundColor Yellow
            write-Host "StartDate: $StartDate" -ForegroundColor Cyan
            write-Host "EndDate: $EndDate" -ForegroundColor Cyan

            $result | ForEach-Object { $_.lastSeen = [datetime]$_.lastSeen }

            ( $result | Measure-Object -Property lastSeen -Minimum ).Minimum | Should -BeGreaterOrEqual $StartDate
            ( $result | Measure-Object -Property lastSeen -Maximum ).Maximum | Should -BeLessOrEqual $EndDate
        }

        It "Should retrieve all devices with pagination" {
            # Arrange

            # Act
            $result = Get-HeimdalDevice -GetAllPages

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -BeGreaterThan 100  # Assuming there are more than 100 devices in the test environment
        }

        It "Should retrieve devices with specified page size and number" {
            # Arrange
            $params = $script:TestGetDeviceData.ByPageSize

            # Act
            $result = Get-HeimdalDevice @params

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -BeLessOrEqual $params.pageSize
        }
    }
}
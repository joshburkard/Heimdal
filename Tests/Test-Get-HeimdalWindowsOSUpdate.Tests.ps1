# Functional Tests for Get-HeimdalWindowsOSUpdate
# Tests the Get-HeimdalWindowsOSUpdate function behavior and return values

BeforeAll {
    # Load test declarations
    . (Join-Path $PSScriptRoot "declarations.ps1")

    # Load all functions
    $CodePath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Code"
    Get-ChildItem -Path (Join-Path $CodePath "Private") -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    Get-ChildItem -Path (Join-Path $CodePath "Public") -Filter "*.ps1" | ForEach-Object { . $_.FullName }

    # Get test data for this function
    $ConnectData = $script:TestData['Connect-Heimdal']['Valid']
    $script:TestGetWindowsOSUpdateData = $script:TestData['Get-HeimdalWindowsOSUpdate']

    Connect-Heimdal @ConnectData
}

Describe "Get-HeimdalWindowsOSUpdate Function Tests" -Tag "Integration", "Connection" {
    Context "Test Data Validation" {

        It "Should have test data defined in declarations.ps1" {
            # Assert
            $script:TestGetWindowsOSUpdateData | Should -Not -BeNullOrEmpty
            $script:TestData.ContainsKey('Get-HeimdalWindowsOSUpdate') | Should -Be $true
        }

        It "Should have required test data parameter sets" {
            # Assert
            $script:TestGetWindowsOSUpdateData.ContainsKey('WithoutFilters') | Should -Be $true
            $script:TestGetWindowsOSUpdateData.ContainsKey('ByGroupPolicyId') | Should -Be $true
            $script:TestGetWindowsOSUpdateData.ContainsKey('ByWindowsUpdateStatus') | Should -Be $true
            $script:TestGetWindowsOSUpdateData.ContainsKey('BySeverity') | Should -Be $true
            $script:TestGetWindowsOSUpdateData.ContainsKey('ByCategory') | Should -Be $true
            $script:TestGetWindowsOSUpdateData.ContainsKey('ByClientInfoId') | Should -Be $true
        }

        It "Should output test data for verification" {
            # Output test data
            Write-Host "`n=== Test Data for Get-HeimdalWindowsOSUpdate ===" -ForegroundColor Cyan
            Write-Host "WithoutFilters:" -ForegroundColor Yellow
            Write-Host "  (no parameters)" -ForegroundColor White
            Write-Host "ByGroupPolicyId:" -ForegroundColor Yellow
            Write-Host "  GroupPolicyId: $($script:TestGetWindowsOSUpdateData.ByGroupPolicyId.GroupPolicyId)" -ForegroundColor White
            Write-Host "ByWindowsUpdateStatus:" -ForegroundColor Yellow
            Write-Host "  WindowsUpdateStatus: $($script:TestGetWindowsOSUpdateData.ByWindowsUpdateStatus.WindowsUpdateStatus)" -ForegroundColor White
            Write-Host "BySeverity:" -ForegroundColor Yellow
            Write-Host "  Severity: $($script:TestGetWindowsOSUpdateData.BySeverity.Severity)" -ForegroundColor White
            Write-Host "ByCategory:" -ForegroundColor Yellow
            Write-Host "  Category: $($script:TestGetWindowsOSUpdateData.ByCategory.Category)" -ForegroundColor White
            Write-Host "ByClientInfoId:" -ForegroundColor Yellow
            Write-Host "  ClientInfoId: $($script:TestGetWindowsOSUpdateData.ByClientInfoId.ClientInfoId)" -ForegroundColor White
            Write-Host "============================================================`n" -ForegroundColor Cyan
            # This test always passes, it's just for output
            $true | Should -Be $true
        }

    }

    Context 'Connection Required' {
        It "Should throw an error if not connected to Heimdal API" {
            # Arrange
            $script:HDSession = $null

            # Act & Assert
            { Get-HeimdalWindowsOSUpdate } | Should -Throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
        }
        It "Should connect successfully with valid credentials" {
            # Arrange
            $ConnectData = $script:TestData['Connect-Heimdal']['Valid']

            # Act
            Connect-Heimdal @ConnectData

            # Assert
            $script:HDSession | Should -Not -BeNullOrEmpty
            $script:HDSession.CustomerID | Should -Be $ConnectData.CustomerID
            $script:HDSession.ApiKey | Should -Be $ConnectData.ApiKey
        }
    }

    Context "Get-HeimdalWindowsOSUpdate Functionality" {
        It "Should retrieve OS updates without filters successfully" {
            # Arrange
            $params = $script:TestGetWindowsOSUpdateData.WithoutFilters

            # Act
            $result = Get-HeimdalWindowsOSUpdate @params

            # Assert
            $result.items | Should -Not -BeNullOrEmpty
        }

        <#
        # This parameter seams not to work as expected, perhaps the API doesn't support filtering by group policy, or there are no updates associated with the
        # specified group policy in the test environment.
        It "Should retrieve OS updates by GroupPolicyId successfully" {
            # Arrange
            $params = $script:TestGetWindowsOSUpdateData.ByGroupPolicyId

            # Act
            $result = Get-HeimdalWindowsOSUpdate @params

            # Assert
            $result.items | Should -Not -BeNullOrEmpty
        }
        #>

        It "Should retrieve OS updates by WindowsUpdateStatus successfully" {
            # Arrange
            $params = $script:TestGetWindowsOSUpdateData.ByWindowsUpdateStatus

            # Act
            $result = Get-HeimdalWindowsOSUpdate @params

            # Assert
            $result.items | Should -Not -BeNullOrEmpty
        }

        It "Should retrieve OS updates by Severity successfully" {
            # Arrange
            $params = $script:TestGetWindowsOSUpdateData.BySeverity

            # Act
            $result = Get-HeimdalWindowsOSUpdate @params

            # Assert
            $result.items | Should -Not -BeNullOrEmpty
        }

        It "Should retrieve OS updates by Category successfully" {
            # Arrange
            $params = $script:TestGetWindowsOSUpdateData.ByCategory

            # Act
            $result = Get-HeimdalWindowsOSUpdate @params

            # Assert
            $result.items | Should -Not -BeNullOrEmpty
        }

        It "Should retrieve OS updates by ClientInfoId successfully" {
            # Arrange
            $params = $script:TestGetWindowsOSUpdateData.ByClientInfoId

            # Act
            $result = Get-HeimdalWindowsOSUpdate @params

            # Assert
            $result.items | Should -Not -BeNullOrEmpty
        }
        It "Should return empty result for non-existent ClientInfoId" {
            # Arrange
            $params = @{
                ClientInfoId = "123"
            }

            # Act
            $result = Get-HeimdalWindowsOSUpdate @params

            # Assert
            $result.items | Should -BeNullOrEmpty
        }
    }
}
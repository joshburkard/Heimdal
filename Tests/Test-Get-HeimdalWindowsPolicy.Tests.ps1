# Functional Tests for Get-HeimdalWindowsPolicy
# Tests the Get-HeimdalWindowsPolicy function behavior and return values

BeforeAll {
    # Load test declarations
    . (Join-Path $PSScriptRoot "declarations.ps1")

    # Load all functions
    $CodePath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Code"
    Get-ChildItem -Path (Join-Path $CodePath "Private") -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    Get-ChildItem -Path (Join-Path $CodePath "Public") -Filter "*.ps1" | ForEach-Object { . $_.FullName }

    # Get test data for this function
    $ConnectData = $script:TestData['Connect-Heimdal']['Valid']
    $script:TestGetWindowsPolicyData = $script:TestData['Get-HeimdalWindowsPolicy']

    Connect-Heimdal @ConnectData
}

Describe "Get-HeimdalWindowsPolicy Function Tests" -Tag "Integration", "Connection" {
    Context "Test Data Validation" {

        It "Should have test data defined in declarations.ps1" {
            # Assert
            $script:TestGetWindowsPolicyData | Should -Not -BeNullOrEmpty
            $script:TestData.ContainsKey('Get-HeimdalWindowsPolicy') | Should -Be $true
        }

        It "Should have required test data parameter sets" {
            # Assert
            $script:TestGetWindowsPolicyData.ContainsKey('ByName') | Should -Be $true
            $script:TestGetWindowsPolicyData.ContainsKey('ById') | Should -Be $true
            $script:TestGetWindowsPolicyData.ContainsKey('ByWrongName') | Should -Be $true
            $script:TestGetWindowsPolicyData.ContainsKey('ByWrongId') | Should -Be $true
        }

        It "Should output test data for verification" {
            # Output test data
            Write-Host "`n=== Test Data for Get-HeimdalWindowsPolicy ===" -ForegroundColor Cyan
            Write-Host "ByName:" -ForegroundColor Yellow
            Write-Host "  Name: $($script:TestGetWindowsPolicyData.ByName.Name)" -ForegroundColor White
            Write-Host "ById:" -ForegroundColor Yellow
            Write-Host "  Id: $($script:TestGetWindowsPolicyData.ById.Id)" -ForegroundColor White
            Write-Host "ByWrongName:" -ForegroundColor Yellow
            Write-Host "  Name: $($script:TestGetWindowsPolicyData.ByWrongName.Name)" -ForegroundColor White
            Write-Host "ByWrongId:" -ForegroundColor Yellow
            Write-Host "  Id: $($script:TestGetWindowsPolicyData.ByWrongId.Id)" -ForegroundColor White
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
            { Get-HeimdalWindowsPolicy } | Should -Throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
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

    Context "Get-HeimdalWindowsPolicy Functionality" {
        It "Should retrieve all group policies when no parameters are provided" {
            # Act
            $result = Get-HeimdalWindowsPolicy

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'Object[]'
        }

        It "Should retrieve the correct policy when filtering by name" {
            # Arrange
            $testName = $script:TestGetWindowsPolicyData.ByName.Name

            # Act
            $result = Get-HeimdalWindowsPolicy -Name $testName

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'PSCustomObject'
            @( $result | Where-Object { $_.name -eq $testName } ).Count | Should -Be 1
        }

        It "Should retrieve the correct policy when filtering by ID" {
            # Arrange
            $testId = $script:TestGetWindowsPolicyData.ById.Id

            # Act
            $result = Get-HeimdalWindowsPolicy -Id $testId

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'PSCustomObject'
            @( $result | Where-Object { $_.id -eq $testId } ).Count | Should -Be 1
        }

        It "Should return an empty array when filtering by a non-existent name" {
            # Arrange
            $wrongName = $script:TestGetWindowsPolicyData.ByWrongName.Name

            # Act
            $result = Get-HeimdalWindowsPolicy -Name $wrongName

            # Assert
            @($result).Count | Should -Be 0
        }
    }
}
# Functional Tests for Get-HeimdalLinuxPolicy
# Tests the Get-HeimdalLinuxPolicy function behavior and return values

BeforeAll {
    # Load test declarations
    . (Join-Path $PSScriptRoot "declarations.ps1")

    # Load all functions
    $CodePath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Code"
    Get-ChildItem -Path (Join-Path $CodePath "Private") -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    Get-ChildItem -Path (Join-Path $CodePath "Public") -Filter "*.ps1" | ForEach-Object { . $_.FullName }

    # Get test data for this function
    $ConnectData = $script:TestData['Connect-Heimdal']['Valid']
    $script:TestGetLinuxPolicyData = $script:TestData['Get-HeimdalLinuxPolicy']

    Connect-Heimdal @ConnectData
}

Describe "Get-HeimdalLinuxPolicy Function Tests" -Tag "Integration", "Connection" {
    Context "Test Data Validation" {

        It "Should have test data defined in declarations.ps1" {
            # Assert
            $script:TestGetLinuxPolicyData | Should -Not -BeNullOrEmpty
            $script:TestData.ContainsKey('Get-HeimdalLinuxPolicy') | Should -Be $true
        }

        It "Should have required test data parameter sets" {
            # Assert
            $script:TestGetLinuxPolicyData.ContainsKey('ByName') | Should -Be $true
            $script:TestGetLinuxPolicyData.ContainsKey('ById') | Should -Be $true
            $script:TestGetLinuxPolicyData.ContainsKey('ByWrongName') | Should -Be $true
            $script:TestGetLinuxPolicyData.ContainsKey('ByWrongId') | Should -Be $true
        }

        It "Should output test data for verification" {
            # Output test data
            Write-Host "`n=== Test Data for Get-HeimdalLinuxPolicy ===" -ForegroundColor Cyan
            Write-Host "ByName:" -ForegroundColor Yellow
            Write-Host "  Name: $($script:TestGetLinuxPolicyData.ByName.Name)" -ForegroundColor White
            Write-Host "ById:" -ForegroundColor Yellow
            Write-Host "  Id: $($script:TestGetLinuxPolicyData.ById.Id)" -ForegroundColor White
            Write-Host "ByWrongName:" -ForegroundColor Yellow
            Write-Host "  Name: $($script:TestGetLinuxPolicyData.ByWrongName.Name)" -ForegroundColor White
            Write-Host "ByWrongId:" -ForegroundColor Yellow
            Write-Host "  Id: $($script:TestGetLinuxPolicyData.ByWrongId.Id)" -ForegroundColor White
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
            { Get-HeimdalLinuxPolicy } | Should -Throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
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

    Context "Get-HeimdalLinuxPolicy Functionality" {
        It "Should retrieve all group policies when no parameters are provided" {
            # Act
            $result = Get-HeimdalLinuxPolicy

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'Object[]'
        }

        It "Should retrieve the correct policy when filtering by name" {
            # Arrange
            $testName = $script:TestGetLinuxPolicyData.ByName.Name

            # Act
            $result = Get-HeimdalLinuxPolicy -Name $testName

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'PSCustomObject'
            @( $result | Where-Object { $_.name -eq $testName } ).Count | Should -Be 1
        }

        It "Should retrieve the correct policy when filtering by ID" {
            # Arrange
            $testId = $script:TestGetLinuxPolicyData.ById.Id

            # Act
            $result = Get-HeimdalLinuxPolicy -Id $testId

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'PSCustomObject'
            @( $result | Where-Object { $_.id -eq $testId } ).Count | Should -Be 1
        }

        It "Should return an empty array when filtering by a non-existent name" {
            # Arrange
            $wrongName = $script:TestGetLinuxPolicyData.ByWrongName.Name

            # Act
            $result = Get-HeimdalLinuxPolicy -Name $wrongName

            # Assert
            @($result).Count | Should -Be 0
        }
    }
}
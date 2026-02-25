# Functional Tests for Get-HeimdalWindowsThirdParty
# Tests the Get-HeimdalWindowsThirdParty function behavior and return values

BeforeAll {
    # Load test declarations
    . (Join-Path $PSScriptRoot "declarations.ps1")

    # Load all functions
    $CodePath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Code"
    Get-ChildItem -Path (Join-Path $CodePath "Private") -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    Get-ChildItem -Path (Join-Path $CodePath "Public") -Filter "*.ps1" | ForEach-Object { . $_.FullName }

    # Get test data for this function
    $ConnectData = $script:TestData['Connect-Heimdal']['Valid']
    $script:TestGetWindowsThirdPartyData = $script:TestData['Get-HeimdalWindowsThirdParty']

    Connect-Heimdal @ConnectData
}

Describe "Get-HeimdalWindowsThirdParty Function Tests" -Tag "Integration", "Connection" {
    Context "Test Data Validation" {

        It "Should have test data defined in declarations.ps1" {
            # Assert
            $script:TestGetWindowsThirdPartyData | Should -Not -BeNullOrEmpty
            $script:TestData.ContainsKey('Get-HeimdalWindowsThirdParty') | Should -Be $true
        }

        It "Should have required test data parameter sets" {
            # Assert
            $script:TestGetWindowsThirdPartyData.ContainsKey('ById') | Should -Be $true
            $script:TestGetWindowsThirdPartyData.ContainsKey('ByStatus') | Should -Be $true
        }

        It "Should output test data for verification" {
            # Output test data
            Write-Host "`n=== Test Data for Get-HeimdalWindowsThirdParty ===" -ForegroundColor Cyan
            Write-Host "ById:" -ForegroundColor Yellow
            Write-Host "  Id: $($script:TestGetWindowsThirdPartyData.ById.ClientInfoId)" -ForegroundColor White
            Write-Host "ByStatus:" -ForegroundColor Yellow
            Write-Host "  Status: $($script:TestGetWindowsThirdPartyData.ByStatus.Status)" -ForegroundColor White
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
            { Get-HeimdalWindowsThirdParty } | Should -Throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
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

    Context "Get-HeimdalWindowsThirdParty Functionality" {
        It "Should retrieve all Windows ThirdParty applications when no parameters are provided" {
            # Act
            $result = Get-HeimdalWindowsThirdParty

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'Object[]'
        }

        It "Should retrieve the correct Windows ThirdParty application when filtering by status" {
            # Arrange
            $testStatus = $script:TestGetWindowsThirdPartyData.ByStatus.Status

            # Act
            $result = Get-HeimdalWindowsThirdParty -Status $testStatus

            # Assert
            $result | Should -Not -BeNullOrEmpty
            @( $result )[0].GetType().Name | Should -Be 'PSCustomObject'
            @( $result | Where-Object { $_.status -eq $testStatus } ).Count | Should -BeGreaterOrEqual 1
        }

        It "Should retrieve the correct Windows ThirdParty application when filtering by ID" {
            # Arrange
            $testId = $script:TestGetWindowsThirdPartyData.ById.ClientInfoId

            # Act
            $result = Get-HeimdalWindowsThirdParty -ClientInfoId $testId

            # Assert
            $result | Should -Not -BeNullOrEmpty
            @( $result )[0].GetType().Name | Should -Be 'PSCustomObject'
            @( $result | Where-Object { $_.ClientInfoId -eq $testId } ).Count | Should -BeGreaterOrEqual 1
        }

        It "Should return an empty array if no applications match the filters" {
            # Arrange
            $nonExistentId = $script:TestGetWindowsThirdPartyData.ByWrongId.ClientInfoId

            # Act
            $result = Get-HeimdalWindowsThirdParty -ClientInfoId $nonExistentId

            # Assert
            $result | Should -BeNullOrEmpty
            @($result).Count | Should -Be 0
        }

        It "Should return only page size number of results when pageSize is specified" {
            # Arrange
            $pageSize = $script:TestGetWindowsThirdPartyData.ByPageSize.PageSize
            $pageNumber = $script:TestGetWindowsThirdPartyData.ByPageSize.PageNumber

            # Act
            $result = Get-HeimdalWindowsThirdParty -pageSize $pageSize -pageNumber $pageNumber

            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -BeLessOrEqual $pageSize
        }
    }
}
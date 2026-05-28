# Functional Tests for Disconnect-Heimdal
# Tests the Disconnect-Heimdal function behavior and effects

BeforeAll {
    # Load test declarations
    . (Join-Path $PSScriptRoot "declarations.ps1")

    # Load all functions
    $CodePath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName "Code"
    Get-ChildItem -Path (Join-Path $CodePath "Private") -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    Get-ChildItem -Path (Join-Path $CodePath "Public") -Filter "*.ps1" | ForEach-Object { . $_.FullName }

    # Get test data for Connect-Heimdal (used to create a session)
    $script:TestConnectData = $script:TestData['Connect-Heimdal']
}

Describe "Disconnect-Heimdal Function Tests" -Tag "Integration", "Connection" {

    Context "Session Disconnection" {

        It "Should clear session when connected" {
            # Arrange: Connect first
            Connect-Heimdal -ApiURL $script:TestConnectData.Valid.ApiURL -CustomerID $script:TestConnectData.Valid.CustomerID -ApiKey $script:TestConnectData.Valid.ApiKey
            $script:HDSession | Should -Not -BeNullOrEmpty

            # Act
            Disconnect-Heimdal

            # Assert
            $script:HDSession | Should -BeNullOrEmpty
        }

        It "Should not throw if no session exists" {
            # Arrange: Ensure session is cleared
            $script:HDSession = $null

            # Act & Assert
            { Disconnect-Heimdal } | Should -Not -Throw
        }
    }
}

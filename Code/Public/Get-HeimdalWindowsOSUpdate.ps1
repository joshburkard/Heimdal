function Get-HeimdalWindowsOSUpdate {
    <#
        .SYNOPSIS
            Retrieves OS updates from Heimdal Security API

        .DESCRIPTION
            This function connects to the Heimdal Security API and retrieves a list of OS updates for a specific device or group policy.
            The API endpoint is /microsoftUpdates and requires customerId, date range, and supports pagination and filtering by clientInfoId, groupPolicyId, windowsUpdateStatus, severity, and category.

        .PARAMETER StartDate
            The start date for filtering (format: YYYY-MM-DDTHH:MM:SS). Defaults to 30 days ago.

        .PARAMETER EndDate
            The end date for filtering (format: YYYY-MM-DDTHH:MM:SS). Defaults to current date/time.

        .PARAMETER ClientInfoId
            Optional filter to retrieve updates for a specific device (identified by clientInfoId)

        .PARAMETER GroupPolicyId
            Optional filter to retrieve updates for devices under a specific group policy (identified by groupPolicyId)

            This parameter wasn't tested successfully. perhaps the API doesn't support filtering by group policy, or
            there are no updates associated with the specified group policy in the test environment.

        .PARAMETER WindowsUpdateStatus
            Optional filter to retrieve updates based on their Windows Update status (e.g., "Pending", "Installed", "Failed")

        .PARAMETER Severity
            Optional filter to retrieve updates based on their severity level (e.g., "Critical", "Important", "Moderate", "Low")

        .PARAMETER Category
            Optional filter to retrieve updates based on their category (e.g., "Security Updates", "Feature Updates", "Definition Updates")

        .EXAMPLE
            Get-HeimdalWindowsOSUpdate -StartDate "2024-05-01T00:00:00" -EndDate "2024-06-01T23:59:59" -ClientInfoId "12345"
            This example retrieves OS updates for the device with clientInfoId "12345" that were reported between May 1, 2024 and June 1, 2024.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$StartDate,

        [Parameter(Mandatory = $false)]
        [string]$EndDate,

        [Parameter(Mandatory = $false)]
        [string]$ClientInfoId,

        [Parameter(Mandatory = $false)]
        [string]$GroupPolicyId,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Installed", "Not Installed", "Failed", "Pending")]
        [string]$WindowsUpdateStatus,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Critical", "Important", "Moderate", "Low")]
        [string]$Severity,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Security Updates", "Updates", "Definition Updates", "Feature Updates", "Update Rollups", "Drivers", "Critical Updates", "Service Packs", "Tools", "Other")]
        [string]$Category
    )
    try {
        Write-Verbose "Connecting to Heimdal Security API..."

        if (-not $script:HDSession) {
            throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
        }

        $endpoint = "$($script:HDSession.ApiURL)/2.0/microsoftUpdates?customerId=$($script:HDSession.CustomerID)"

        # Set default dates if not provided
        if ([boolean]$StartDate) {
            $StartDateString = (Get-Date -Date $StartDate).ToString("yyyy-MM-ddT00:00:00")
            $endpoint += "&startDate=$StartDateString"
        }
        if ([boolean]$EndDate) {
            $EndDateString = (Get-Date -Date $EndDate).ToString("yyyy-MM-ddTHH:mm:ss")
            $endpoint += "&endDate=$EndDateString"
        }

        # Add optional filters to endpoint
        if ([boolean]$ClientInfoId) {
            $endpoint += "&clientInfoId=$ClientInfoId"
        }
        if ([boolean]$GroupPolicyId) {
            $endpoint += "&groupPolicyId=$GroupPolicyId"
        }
        if ([boolean]$WindowsUpdateStatus) {
            $WindowsUpdateStatusString = $WindowsUpdateStatus -replace " ", ""
            $WindowsUpdateStatusString = $WindowsUpdateStatusString.ToLower()
            $endpoint += "&windowsUpdateStatus=$WindowsUpdateStatusString"
        }
        if ([boolean]$Severity) {
            $SeverityString = $Severity.ToLower()
            $endpoint += "&severity=$SeverityString"
        }
        if ($Category) {
            $CategoryString = $Category -replace " ", "%20"
            $CategoryString = $CategoryString.ToLower()
            $endpoint += "&category=$CategoryString"
        }

        Write-Verbose "Fetching OS updates from Heimdal API..."

        # Set up the headers with API key authentication
        $headers = @{
            "Authorization" = "Bearer $($script:HDSession.ApiKey)"
            "Accept" = "application/json"
        }

        # Make the API call
        write-Verbose "API Endpoint: $endpoint"
        $response = Invoke-HeimdalApiRequest -Uri $endpoint -Headers $headers -Method GET

        if ($response) {
            Write-Verbose "Successfully retrieved OS updates from Heimdal"
            return $response
        }
        else {
            Write-Verbose "No OS updates found in Heimdal API response"
            return @()
        }
    }
    catch {
        Write-Verbose "Failed to retrieve OS updates from Heimdal API"
        Write-Verbose "Error: $($_.Exception.Message)"

        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Verbose "HTTP Status Code: $statusCode"
        }

        throw
    }
}

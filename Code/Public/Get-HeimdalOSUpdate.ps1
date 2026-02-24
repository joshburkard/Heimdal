function Get-HeimdalOSUpdate {
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

        .PARAMETER WindowsUpdateStatus
            Optional filter to retrieve updates based on their Windows Update status (e.g., "Pending", "Installed", "Failed")

        .PARAMETER Severity
            Optional filter to retrieve updates based on their severity level (e.g., "Critical", "Important", "Moderate", "Low")

        .PARAMETER Category
            Optional filter to retrieve updates based on their category (e.g., "Security Updates", "Feature Updates", "Definition Updates")

        .EXAMPLE
            Get-HeimdalOSUpdate -StartDate "2024-05-01T00:00:00" -EndDate "2024-06-01T23:59:59" -ClientInfoId "12345"
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
        [string]$WindowsUpdateStatus,

        [Parameter(Mandatory = $false)]
        [string]$Severity,

        [Parameter(Mandatory = $false)]
        [string]$Category
    )
    try {
        Write-Verbose "Connecting to Heimdal Security API..."

        if (-not $script:HDSession) {
            throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
        }

        # get devices
        $devices = Get-HeimdalDevices

        $endpoint = "${script:HDSession.ApiURL}/2.0/microsoftUpdates?customerId=${script:HDSession.CustomerID}"

        # Set default dates if not provided
        if (-not $StartDate) {
            $StartDate = (Get-Date).AddDays(-30).ToString("yyyy-MM-ddT00:00:00")
            $endpoint += "&startDate=$StartDate"
        }
        if (-not $EndDate) {
            $EndDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
            $endpoint += "&endDate=$EndDate"
        }

        # Add optional filters to endpoint
        if ($ClientInfoId) {
            $endpoint += "&clientInfoId=$ClientInfoId"
        }
        if ($GroupPolicyId) {
            $endpoint += "&groupPolicyId=$GroupPolicyId"
        }
        if ($WindowsUpdateStatus) {
            $endpoint += "&windowsUpdateStatus=$WindowsUpdateStatus"
        }
        if ($Severity) {
            $endpoint += "&severity=$Severity"
        }
        if ($Category) {
            $endpoint += "&category=$Category"
        }

        Write-Verbose "Fetching OS updates from Heimdal API..."

        # Set up the headers with API key authentication
        $headers = @{
            "Authorization" = "Bearer $($script:HDSession.ApiKey)"
            "Accept" = "application/json"
        }

        # Make the API call
        $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers $headers -ErrorAction Stop

        # map devices to updates
        if ($response -and $response.items) {
            foreach ($update in $response.items) {
                $device = $devices | Where-Object { $_.id -eq $update.clientInfoId }
                if ($device) {
                    $update | Add-Member -MemberType NoteProperty -Name "DeviceHostname" -Value $device.hostname
                    $update | Add-Member -MemberType NoteProperty -Name "DeviceLastSeen" -Value $device.lastSeen
                }
            }
        }

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

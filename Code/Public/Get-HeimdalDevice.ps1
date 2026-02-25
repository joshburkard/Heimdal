function Get-HeimdalDevice {
    <#
        .SYNOPSIS
            Retrieves devices from Heimdal Security API

        .DESCRIPTION
            This function retrieves a list of all available devices (active clients) from the Heimdal Security API.
            The API endpoint is /activeclients and requires customerId, date range, and supports pagination.

        .PARAMETER Name
            Filter devices by hostname

        .PARAMETER ClientInfoId
            Filter devices by clientInfoId

        .PARAMETER StartDate
            The start date for filtering

        .PARAMETER EndDate
            The end date for filtering

        .PARAMETER pageSize
            (Optional) Number of results per page. If not provided, all results will be returned.

        .PARAMETER pageNumber
            (Optional) Page number to retrieve. If not provided, all results will be returned.

        .EXAMPLE
            Get-HeimdalDevice -ApiKey "YOUR_API_KEY" -CustomerId "123456" -BaseUrl "https://dashboard.heimdalsecurity.com/api/heimdalapi"

    #>
    [CmdletBinding()]
    param (
        [string]$Name,
        [string]$ClientInfoId,
        [Parameter(Mandatory = $false)]
        [datetime]$StartDate,

        [Parameter(Mandatory = $false)]
        [datetime]$EndDate,
        [int]$pageSize,
        [int]$pageNumber
    )

    try {
        Write-Verbose "Connecting to Heimdal Security API..."

        if (-not $script:HDSession) {
            throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
        }

        $endpoint = "$($script:HDSession.ApiURL)/2.0/activeclients?customerId=$($script:HDSession.CustomerID)"

        if ($ClientInfoId) {
            $endpoint += "&clientInfoId=$ClientInfoId"
        }

        # Set default dates if not provided
        if ([boolean]$StartDate) {
            $StartDateString = (Get-Date $StartDate).ToUniversalTime().ToString("yyyy-MM-ddT00:00:00")
            $endpoint += "&startDate=$StartDateString"
        }
        if ([boolean]$EndDate) {
            $EndDateString = (Get-Date $EndDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss")
            $endpoint += "&endDate=$EndDateString"
        }

        Write-Verbose "Date range: $StartDate to $EndDate"

        # Set up the headers with API key authentication
        $headers = @{
            "Authorization" = "Bearer $($script:HDSession.ApiKey)"
            "Accept" = "application/json"
        }

        # Initialize results array
        $allDevices = @()

        Write-Verbose "Fetching devices from Heimdal API..."

        $invokeParams = @{
            Uri     = $endpoint
            Headers = $headers
        }
        if ($pageSize)   { $invokeParams.Add("pageSize", $pageSize) }
        if ($pageNumber) { $invokeParams.Add("pageNumber", $pageNumber) }

        # If neither pageSize nor pageNumber are set, let Invoke-HeimdalApiRequest handle paging (GetAllPages behavior)
        $response = Invoke-HeimdalApiRequest @invokeParams
        if ($response) {
            $allDevices = $response.items
            Write-Verbose "Retrieved $($response.items.Count) devices."
        }

        if ($Name) {
            $allDevices = $allDevices | Where-Object { $_.hostname -eq $Name }
        }

        Write-Verbose "Successfully retrieved $($allDevices.Count) total devices from Heimdal"
        return $allDevices
    }
    catch {
        Write-Verbose "Failed to retrieve devices from Heimdal API"
        Write-Verbose "Error: $($_.Exception.Message)"

        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Verbose "HTTP Status Code: $statusCode"
        }

        throw
    }
}

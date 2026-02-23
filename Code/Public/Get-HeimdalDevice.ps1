function Get-HeimdalDevice {
    <#
        .SYNOPSIS
            Retrieves all devices from Heimdal Security API

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
            Number of results per page (default: 1000)

        .PARAMETER pageNumber
            Page number to retrieve (default: 1)

        .PARAMETER GetAllPages
            Switch to indicate whether to retrieve all pages of results

        .EXAMPLE
            Get-HeimdalDevice -ApiKey "YOUR_API_KEY" -CustomerId "123456" -BaseUrl "https://dashboard.heimdalsecurity.com/api/heimdalapi" -GetAllPages

        .OUTPUTS
            Returns an array of device objects from Heimdal
    #>
    [CmdletBinding()]
    param (
        [string]$Name,
        [string]$ClientInfoId,
        [Parameter(Mandatory = $false)]
        [datetime]$StartDate,

        [Parameter(Mandatory = $false)]
        [datetime]$EndDate
        ,
        [int]$pageSize = 1000,
        [int]$pageNumber = 1,
        [switch]$GetAllPages
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

        if ([boolean]$GetAllPages -or [boolean]$Name) {
            $pageSize = 1000  # Use maximum page size to minimize number of requests
            $pageNumber = 1
            do {
                Write-Verbose "Requesting page $pageNumber with page size $pageSize..."
                $URI = "$endpoint&pageSize=$pageSize&pageNumber=$pageNumber"
                Write-Verbose "Request URI: $URI"
                $response = Invoke-HeimdalApiRequest -Uri $URI -Method Get -Headers $headers

                if ($response) {
                    $allDevices += $response.items
                    Write-Verbose "Retrieved $($response.items.Count) devices from page $pageNumber."
                }

                $pageNumber++
            } while ($response.totalCount -gt $allDevices.Count)
        }
        else {
            # If not fetching all pages, just get the first page
            Write-Verbose "Requesting first page with page size $pageSize..."
            $URI = "$endpoint&pageSize=$pageSize&pageNumber=$pageNumber"
            Write-Verbose "Request URI: $URI"
            $response = Invoke-HeimdalApiRequest -Uri $URI -Method Get -Headers $headers
            if ($response) {
                $allDevices = $response.items
                Write-Verbose "Retrieved $($response.items.Count) devices from first page."
            }
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

function Get-HeimdalDeviceInfo {
    <#
        .SYNOPSIS
            Retrieves device information from Heimdal Security API

        .DESCRIPTION
            This function retrieves a list of all available devices (active clients) from the Heimdal Security API.
            The API endpoint is /activeclients and requires date range, and supports pagination.

            This API endpoint retrieves information about the hardware specifications of an endpoint. This request works only when specifying the clientInfoId of an endpoint.
            It does not list all endpoints in one request.

        .PARAMETER ClientInfoId
            Filter devices by clientInfoId

        .EXAMPLE
            Get-HeimdalDeviceInfo -ClientInfoId "12345"

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ClientInfoId
    )

    try {
        Write-Verbose "Connecting to Heimdal Security API..."

        if (-not $script:HDSession) {
            throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
        }

        $endpoint = "$($script:HDSession.ApiURL)/2.0/activeclients/getDeviceInfo?customerId=$($script:HDSession.CustomerID)&clientInfoId=${ClientInfoId}"

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

        # If neither pageSize nor pageNumber are set, let Invoke-HeimdalApiRequest handle paging (GetAllPages behavior)
        $response = Invoke-HeimdalApiRequest @invokeParams -ErrorAction SilentlyContinue
        if ($response) {
            $allDevices = $response.items
            Write-Verbose "Retrieved $($response.items.Count) devices."
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

function Get-HeimdalWindowsThirdParty {
    <#
        .Synopsis
            Retrieves patch information from the Heimdal Security API.

        .Description
            This function connects to the Heimdal Security API and retrieves information about patches.
            You can filter the results by providing a patch ID or patch name.

        .Parameter ClientInfoId
            The ID of the client to retrieve third-party patch information for.

        .Parameter Status
            Filter patches by status. Valid values are "latest", "update", "vulnerable", "patched", "uninstalled".

        .PARAMETER pageSize
            (Optional) Number of results per page. If not provided, all results will be returned.

        .PARAMETER pageNumber
            (Optional) Page number to retrieve. If not provided, all results will be returned.

        .EXAMPLE
            Get-HeimdalWindowsThirdParty -ClientInfoId 12345

        .EXAMPLE
            Get-HeimdalWindowsThirdParty -Status "vulnerable"

    #>
    [CmdletBinding()]
    param (
        [int]$ClientInfoId,

        [ValidateSet("latest", "update", "vulnerable", "patched", "uninstalled")]
        [string]$Status,
        [int]$pageSize,
        [int]$pageNumber
    )

    if (-not $script:HDSession) {
        throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
    }

    try {
        Write-Verbose "Connecting to Heimdal Security API..."

        $endpoint = "$($script:HDSession.ApiURL)/2.0/thirdparty?customerId=$($script:HDSession.CustomerID)"

        if ($ClientInfoId) {
            $endpoint += "&clientInfoId=$ClientInfoId"
        }
        if ($Status) {
            $endpoint += "&status=$Status"
        }

        # Set up the headers with API key authentication
        $headers = @{
            "Authorization" = "Bearer $($script:HDSession.ApiKey)"
            "Accept" = "application/json"
        }

        Write-Verbose "Fetching patches from Heimdal API..."
        write-Verbose "API Endpoint: $endpoint"

        # Make the API call
        $invokeParams = @{
            Uri     = $endpoint
            Headers = $headers
        }
        if ($pageSize)   { $invokeParams.Add("pageSize", $pageSize) }
        if ($pageNumber) { $invokeParams.Add("pageNumber", $pageNumber) }

        $response = Invoke-HeimdalApiRequest @invokeParams

        if ($response) {
            Write-Verbose "Successfully retrieved patches from Heimdal"

            $items = $response | Select-Object -ExpandProperty items

            return @($items)
        }
        else {
            Write-Verbose "No patches found in Heimdal API response"
            return @()
        }
    }
    catch {
        Write-Error "An error occurred while retrieving patches from Heimdal API: $_"
    }
}

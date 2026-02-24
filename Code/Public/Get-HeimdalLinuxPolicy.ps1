function Get-HeimdalLinuxPolicy {
    <#
        .SYNOPSIS
            Retrieves Linux policies from Heimdal Security API

        .DESCRIPTION
            This function connects to the Heimdal Security API and retrieves a list of all Linux policies.
            The API endpoint is /groupPolicy/getLinuxPolicies and requires customerId.

        .EXAMPLE
            Get-HeimdalLinuxPolicy

        .OUTPUTS
            Returns an array of Linux policy objects from Heimdal

        https://dashboard.heimdalsecurity.com/api/heimdalapi/2.0/groupPolicy/getLinuxPolicies?customerId=229584&pageNumber=1&pageSize=2
    #>
    [CmdletBinding()]
    param (
    )
    try {
        Write-Verbose "Connecting to Heimdal Security API..."

        if (-not $script:HDSession) {
            throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
        }

        $endpoint = "${script:HDSession.ApiURL}/2.0/groupPolicy/getLinuxPolicies?customerId=${script:HDSession.CustomerID}"

        # Set up the headers with API key authentication
        $headers = @{
            "Authorization" = "Bearer $($script:HDSession.ApiKey)"
            "Accept" = "application/json"
        }

        Write-Verbose "Fetching Linux policies from Heimdal API..."

        # Make the API call
        $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers $headers -ErrorAction Stop

        if ($response) {
            Write-Verbose "Successfully retrieved Linux policies from Heimdal"
            return $response
        }
        else {
            Write-Verbose "No Linux policies found in Heimdal API response"
            return @()
        }
    }
    catch {
        Write-Verbose "Failed to retrieve Linux policies from Heimdal API"
        Write-Verbose "Error: $($_.Exception.Message)"

        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Verbose "HTTP Status Code: $statusCode"
        }

        throw
    }

}

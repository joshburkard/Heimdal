function Get-HeimdalWindowsPolicy {
    <#
        .SYNOPSIS
            Retrieves all group policies from Heimdal Security API

        .DESCRIPTION
            This function connects to the Heimdal Security API and retrieves a list of all group policies.
            The API endpoint is /groupPolicy/getWindowsPolicies and requires customerId.

        .EXAMPLE
            Get-HeimdalWindowsPolicy

        .OUTPUTS
            Returns an array of group policy objects from Heimdal
    #>
    # https://dashboard.heimdalsecurity.com/api/heimdalapi/2.0/groupPolicy/getWindowsPolicies?customerId=229584

    [CmdletBinding()]
    param (
    )
    try {
        Write-Verbose "Connecting to Heimdal Security API..."

        if (-not $script:HDSession) {
            throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
        }

        $endpoint = "${script:HDSession.ApiURL}/2.0/groupPolicy/getWindowsPolicies?customerId=${script:HDSession.CustomerID}"

        # Set up the headers with API key authentication
        $headers = @{
            "Authorization" = "Bearer $($script:HDSession.ApiKey)"
            "Accept" = "application/json"
        }

        Write-Verbose "Fetching group policies from Heimdal API..."

        # Make the API call
        $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers $headers -ErrorAction Stop

        if ($response) {
            Write-Verbose "Successfully retrieved group policies from Heimdal"
            return $response
        }
        else {
            Write-Verbose "No group policies found in Heimdal API response"
            return @()
        }
    }
    catch {
        Write-Verbose "Failed to retrieve group policies from Heimdal API"
        Write-Verbose "Error: $($_.Exception.Message)"

        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Verbose "HTTP Status Code: $statusCode"
        }

        throw
    }

}

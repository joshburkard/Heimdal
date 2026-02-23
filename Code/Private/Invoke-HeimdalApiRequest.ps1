function Invoke-HeimdalApiRequest {
    <#
        .SYNOPSIS
            Helper to invoke Heimdal API requests with 429 retry logic.

        .DESCRIPTION
            Invokes a web request to the Heimdal API, handling 429 Too Many Requests responses by waiting and retrying.
            Retries up to a maximum number of attempts, with exponential backoff.

        .PARAMETER Uri
            The URI to request.
        .PARAMETER Method
            The HTTP method (GET, POST, etc). Defaults to GET.
        .PARAMETER Headers
            Hashtable of headers to include.
        .PARAMETER Body
            Optional body for POST/PUT requests.
        .PARAMETER MaxRetries
            Maximum number of retries for 429 responses. Default: 5.
        .PARAMETER InitialDelaySeconds
            Initial delay in seconds before retrying after 429. Default: 60.
        .OUTPUTS
            The response object from Invoke-RestMethod.

        .EXAMPLE
            $headers = @{ "Authorization" = "Bearer your_api_key_here" }
            $response = Invoke-HeimdalApiRequest -Uri "https://dashboard.heimdalsecurity.com/api/heimdalapi/2.0/activeclients?customerid=12345&pageSize=10&pageNumber=1" -Method Get -Headers $headers
            This example makes a GET request to the Heimdal API to retrieve active clients, with retry logic for 429 responses.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri,
        [Parameter()]
        [ValidateSet('GET','POST','PUT','DELETE')]
        [string]$Method = 'GET',
        [Parameter()]
        [hashtable]$Headers,
        [Parameter()]
        $Body,
        [Parameter()]
        [int]$MaxRetries = 5,
        [Parameter()]
        [int]$InitialDelaySeconds = 60
    )

    $attempt = 0
    $delay = $InitialDelaySeconds
    do {
        try {
            Write-Verbose "Attempting API request to $Uri (Attempt $($attempt+1)/$MaxRetries)"
            $response = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ErrorAction Stop
            try { $script:HDSession.LastRequest = Get-Date } catch {}
            return $response
        } catch {
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429) {
                # calculate how long delay should be based on time since last request, with a minimum of InitialDelaySeconds
                $timeSinceLastRequest = (Get-Date) - $script:HDSession.LastRequest
                if ($timeSinceLastRequest.TotalSeconds -gt $delay) {
                    $delay = 0
                } elseif ($timeSinceLastRequest.TotalSeconds -gt 0) {
                    $delay = $delay - $timeSinceLastRequest.TotalSeconds
                }

                Write-Warning "Received 429 Too Many Requests. Waiting $delay seconds before retrying... (Attempt $($attempt+1)/$MaxRetries)"
                Start-Sleep -Seconds $delay
                $attempt++
                $delay = [Math]::Min($delay * 2, 120) # Exponential backoff, max 2 minutes
            } else {
                throw
            }
        }
    } while ($attempt -lt $MaxRetries)
    throw "Failed after $MaxRetries attempts due to repeated 429 responses."
}

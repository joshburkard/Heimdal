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
        [int]$InitialDelaySeconds = 60,
        [Parameter()]
        [int]$pageSize,
        [Parameter()]
        [int]$pageNumber
    )

    # If pageSize or pageNumber are provided, add them to the URI (single page mode)
    $uriWithPaging = $Uri
    $pagingParams = @()
    if ($PSBoundParameters.ContainsKey('pageSize')) { $pagingParams += "pageSize=$pageSize" }
    if ($PSBoundParameters.ContainsKey('pageNumber')) { $pagingParams += "pageNumber=$pageNumber" }
    if ($pagingParams.Count -gt 0) {
        if ($Uri -match '\?') {
            $uriWithPaging += "&" + ($pagingParams -join "&")
        } else {
            $uriWithPaging += "?" + ($pagingParams -join "&")
        }
    }

    if ($pagingParams.Count -gt 0) {
        # Single page request
        $attempt = 0
        $delay = $InitialDelaySeconds
        do {
            try {
                Write-Verbose "Attempting API request to $uriWithPaging (Attempt $($attempt+1)/$MaxRetries)"
                $response = Invoke-RestMethod -Uri $uriWithPaging -Method $Method -Headers $Headers -Body $Body -ErrorAction Stop
                try { $script:HDSession.LastRequest = Get-Date } catch {}
                return $response
            } catch {
                if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429) {
                    $timeSinceLastRequest = (Get-Date) - $script:HDSession.LastRequest
                    if ($timeSinceLastRequest.TotalSeconds -gt $delay) {
                        $delay = 0
                    } elseif ($timeSinceLastRequest.TotalSeconds -gt 0) {
                        $delay = $delay - $timeSinceLastRequest.TotalSeconds
                    }
                    Write-Warning "Received 429 Too Many Requests. Waiting $delay seconds before retrying... (Attempt $($attempt+1)/$MaxRetries)"
                    Start-Sleep -Seconds $delay
                    $attempt++
                    $delay = [Math]::Min($delay * 2, 120)
                } else {
                    throw
                }
            }
        } while ($attempt -lt $MaxRetries)
        throw "Failed after $MaxRetries attempts due to repeated 429 responses."
    } else {
        # No pageSize/pageNumber: fetch all pages
        $allItems = @()
        $autoPageSize = 1000
        $autoPageNumber = 1
        $totalCount = $null
        do {
            if ($Uri -match '\?') {
                $pageUri = $Uri + "&pageSize=$autoPageSize&pageNumber=$autoPageNumber"
            } else {
                $pageUri = $Uri + "?pageSize=$autoPageSize&pageNumber=$autoPageNumber"
            }
            $attempt = 0
            $delay = $InitialDelaySeconds
            do {
                try {
                    Write-Verbose "Attempting API request to $pageUri (Attempt $($attempt+1)/$MaxRetries)"
                    $response = Invoke-RestMethod -Uri $pageUri -Method $Method -Headers $Headers -Body $Body -ErrorAction Stop
                    try { $script:HDSession.LastRequest = Get-Date } catch {}
                    break
                } catch {
                    if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 429) {
                        $timeSinceLastRequest = (Get-Date) - $script:HDSession.LastRequest
                        if ($timeSinceLastRequest.TotalSeconds -gt $delay) {
                            $delay = 0
                        } elseif ($timeSinceLastRequest.TotalSeconds -gt 0) {
                            $delay = $delay - $timeSinceLastRequest.TotalSeconds
                        }
                        Write-Warning "Received 429 Too Many Requests. Waiting $delay seconds before retrying... (Attempt $($attempt+1)/$MaxRetries)"
                        Start-Sleep -Seconds $delay
                        $attempt++
                        $delay = [Math]::Min($delay * 2, 120)
                    } else {
                        throw
                    }
                }
            } while ($attempt -lt $MaxRetries)
            if ($attempt -ge $MaxRetries) {
                throw "Failed after $MaxRetries attempts due to repeated 429 responses."
            }
            if ($response -and $response.items) {
                $allItems += $response.items
                $totalCount = $response.totalCount
            }
            $autoPageNumber++
        } while ($totalCount -gt $allItems.Count)
        # Return a response-like object with all items
        $result = [PSCustomObject]@{
            items = $allItems
            totalCount = $totalCount
        }
        return $result
    }
}

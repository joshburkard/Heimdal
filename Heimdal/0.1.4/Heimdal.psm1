<#
    Generated at 02/25/2026 07:50:39 by Josua Burkard
#>
#region namespace Heimdal
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
function Connect-Heimdal {
    <#
        .Synopsis
            Connects to the Heimdal Security API and stores the session information in a global variable.

        .Description
            This function establishes a connection to the Heimdal Security API using the provided API URL, Customer
            ID, and API Key. The session information is stored in a global variable for use in subsequent API calls.

        .Parameter ApiURL
            The URL of the Heimdal Security API.

        .Parameter CustomerID
            The customer ID for the Heimdal Security account.

        .Parameter ApiKey
            The API key for the Heimdal Security account.

        .Example
            Connect-Heimdal -ApiURL "https://dashboard.heimdalsecurity.com/api/heimdalapi" -CustomerID "12345" -ApiKey "your_api_key_here"
            This example connects to the Heimdal Security API using the specified API URL, Customer ID, and API Key.
    #>
    [CmdletBinding()]
    param (
        [string]$ApiURL = "https://dashboard.heimdalsecurity.com/api/heimdalapi",
        [string]$CustomerID,
        [string]$ApiKey
    )

    # Test the connection to the API by making a simple request (e.g., get customer information)
    try {
        $response = Invoke-HeimdalApiRequest -Uri "$ApiURL/2.0/activeclients?customerid=$CustomerID&pageSize=10&pageNumber=1" -Headers @{ "Authorization" = "Bearer $ApiKey" }

        if ( [boolean]( $response | get-member -Name "message" -ErrorAction SilentlyContinue ) ) {
            # the response contains a "message" property, which indicates an error (e.g., invalid credentials)
            throw "Invalid credentials provided for Heimdal Security API."
        }
        Write-Verbose "Successfully connected to Heimdal Security API. Customer Name: $($response.name)"
    } catch {
        throw "Failed to connect to Heimdal Security API. Please check your API URL."
    }
    # Store the session information in a global variable

    $script:HDSession = @{
        ApiURL = $ApiURL
        CustomerID = $CustomerID
        ApiKey = $ApiKey
        LastRequest = (Get-Date)
    }

    return $script:HDSession
}
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
function Get-HeimdalLinuxPolicy {
    <#
        .SYNOPSIS
            Retrieves Linux policies from Heimdal Security API

        .DESCRIPTION
            This function connects to the Heimdal Security API and retrieves a list of all Linux policies.
            The API endpoint is /groupPolicy/getLinuxPolicies and requires customerId.

        .PARAMETER Id
            (Optional) The ID of a specific Linux policy to retrieve. If not provided, all policies will be returned.

        .PARAMETER Name
            (Optional) The name of a specific Linux policy to retrieve. If not provided, all policies will be returned.

        .EXAMPLE
            Get-HeimdalLinuxPolicy

        .EXAMPLE
            Get-HeimdalLinuxPolicy -Id 123

        .EXAMPLE
            Get-HeimdalLinuxPolicy -Name "PolicyName"

        .OUTPUTS
            Returns an array of Linux policy objects from Heimdal

        https://dashboard.heimdalsecurity.com/api/heimdalapi/2.0/groupPolicy/getLinuxPolicies?customerId=229584&pageNumber=1&pageSize=2
    #>
    [CmdletBinding()]
    param (
        [int]$Id,
        [string]$Name
    )
    try {
        Write-Verbose "Connecting to Heimdal Security API..."

        if (-not $script:HDSession) {
            throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
        }

        $endpoint = "$($script:HDSession.ApiURL)/2.0/groupPolicy/getLinuxPolicies?customerId=$($script:HDSession.CustomerID)"

        # Set up the headers with API key authentication
        $headers = @{
            "Authorization" = "Bearer $($script:HDSession.ApiKey)"
            "Accept" = "application/json"
        }

        Write-Verbose "Fetching Linux policies from Heimdal API..."
        write-verbose "API Endpoint: $endpoint"
        # Make the API call
        $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers $headers -ErrorAction Stop

        if ($response) {
            Write-Verbose "Successfully retrieved Linux policies from Heimdal"

            $items = $response | Select-Object -ExpandProperty items
            if ($Id) {
                $items = $items | Where-Object { $_.id -eq $Id }
            }
            if ($Name) {
                $items = $items | Where-Object { $_.name -eq $Name }
            }
            return $items
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
function Get-HeimdalWindowsPolicy {
    <#
        .SYNOPSIS
            Retrieves all group policies from Heimdal Security API

        .DESCRIPTION
            This function connects to the Heimdal Security API and retrieves a list of all group policies.
            The API endpoint is /groupPolicy/getWindowsPolicies and requires customerId.

        .PARAMETER id
            (Optional) The ID of a specific group policy to retrieve. If not provided, all policies will be returned.

        .PARAMETER name
            (Optional) The name of a specific group policy to retrieve. If not provided, all policies will be returned.

        .EXAMPLE
            Get-HeimdalWindowsPolicy

        .EXAMPLE
            Get-HeimdalWindowsPolicy -Id 123

        .EXAMPLE
            Get-HeimdalWindowsPolicy -Name "PolicyName"

        .OUTPUTS
            Returns an array of group policy objects from Heimdal
    #>
    # https://dashboard.heimdalsecurity.com/api/heimdalapi/2.0/groupPolicy/getWindowsPolicies?customerId=229584

    [CmdletBinding()]
    param (
        [int]$Id,
        [string]$Name
    )
    try {
        Write-Verbose "Connecting to Heimdal Security API..."

        if (-not $script:HDSession) {
            throw "Not connected to Heimdal API. Please run Connect-Heimdal first."
        }

        $endpoint = "$($script:HDSession.ApiURL)/2.0/groupPolicy/getWindowsPolicies?customerId=$($script:HDSession.CustomerID)"

        # Set up the headers with API key authentication
        $headers = @{
            "Authorization" = "Bearer $($script:HDSession.ApiKey)"
            "Accept" = "application/json"
        }

        Write-Verbose "Fetching group policies from Heimdal API..."
        write-Verbose "API Endpoint: $endpoint"

        # Make the API call
        $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers $headers -ErrorAction Stop

        if ($response) {
            Write-Verbose "Successfully retrieved group policies from Heimdal"

            $items = $response | Select-Object -ExpandProperty items

            if ($Id) {
                $items = $items | Where-Object { $_.id -eq $Id }
            }
            if ($Name) {
                $items = $items | Where-Object { $_.name -eq $Name }
            }

            return @($items)
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
#endregion

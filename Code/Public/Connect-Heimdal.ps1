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

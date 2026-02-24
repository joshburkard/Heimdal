# Connect-Heimdal

## SYNOPSIS
Connects to the Heimdal Security API and stores the session information in a global variable.

## DESCRIPTION
This function establishes a connection to the Heimdal Security API using the provided API URL, Customer
ID, and API Key. The session information is stored in a global variable for use in subsequent API calls.

## PARAMETERS

### ApiURL
The URL of the Heimdal Security API.

- Type: String
- Required: false
- Default value: https://dashboard.heimdalsecurity.com/api/heimdalapi
- Accept pipeline input: false
- Accept wildcard characters: false

### CustomerID
The customer ID for the Heimdal Security account.

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### ApiKey
The API key for the Heimdal Security account.

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

## EXAMPLES

### Example 1
```powershell
Connect-Heimdal -ApiURL "https://dashboard.heimdalsecurity.com/api/heimdalapi" -CustomerID "12345" -ApiKey "your_api_key_here"
            This example connects to the Heimdal Security API using the specified API URL, Customer ID, and API Key.
```

# Invoke-HeimdalApiRequest

## SYNOPSIS

Helper to invoke Heimdal API requests with 429 retry logic.

## DESCRIPTION

Invokes a web request to the Heimdal API, handling 429 Too Many Requests responses by waiting and retrying.
Retries up to a maximum number of attempts, with exponential backoff.

## PARAMETERS

### Uri

The URI to request.

- Type: String
- Required: true
- Accept pipeline input: false
- Accept wildcard characters: false

### Method

The HTTP method (GET, POST, etc). Defaults to GET.

- Type: String
- Required: false
- Default value: GET
- Accept pipeline input: false
- Accept wildcard characters: false

### Headers

Hashtable of headers to include.

- Type: Hashtable
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### Body

Optional body for POST/PUT requests.

- Type: Object
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### MaxRetries

Maximum number of retries for 429 responses. Default: 5.

- Type: Int32
- Required: false
- Default value: 5
- Accept pipeline input: false
- Accept wildcard characters: false

### InitialDelaySeconds

Initial delay in seconds before retrying after 429. Default: 60.

- Type: Int32
- Required: false
- Default value: 60
- Accept pipeline input: false
- Accept wildcard characters: false

## EXAMPLES

### Example 1

```powershell
$headers = @{ "Authorization" = "Bearer your_api_key_here" }
            $response = Invoke-HeimdalApiRequest -Uri "https://dashboard.heimdalsecurity.com/api/heimdalapi/2.0/activeclients?customerid=12345&pageSize=10&pageNumber=1" -Method Get -Headers $headers
            This example makes a GET request to the Heimdal API to retrieve active clients, with retry logic for 429 responses.
```

# Get-HeimdalDevice

## SYNOPSIS

Retrieves devices from Heimdal Security API

## DESCRIPTION

This function retrieves a list of all available devices (active clients) from the Heimdal Security API.
The API endpoint is /activeclients and requires customerId, date range, and supports pagination.

## PARAMETERS

### Name

Filter devices by hostname

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### ClientInfoId

Filter devices by clientInfoId

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### StartDate

The start date for filtering

- Type: DateTime
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### EndDate

The end date for filtering

- Type: DateTime
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### pageSize

(Optional) Number of results per page. If not provided, all results will be returned.

- Type: Int32
- Required: false
- Default value: 0
- Accept pipeline input: false
- Accept wildcard characters: false

### pageNumber

(Optional) Page number to retrieve. If not provided, all results will be returned.

- Type: Int32
- Required: false
- Default value: 0
- Accept pipeline input: false
- Accept wildcard characters: false

## EXAMPLES

### Example 1

```powershell
Get-HeimdalDevice -ApiKey "YOUR_API_KEY" -CustomerId "123456" -BaseUrl "https://dashboard.heimdalsecurity.com/api/heimdalapi"
```

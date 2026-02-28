# Get-HeimdalActiveClient

## SYNOPSIS

Retrieves active clients from Heimdal Security API

## DESCRIPTION

This function retrieves a list of all available active clients from the Heimdal Security API.
The API endpoint is /activeclients and requires customerId, date range, and supports pagination.

This API endpoint retrieves information about all the active clients of a customer (id, hostname, IP Address, Agent version, OS, current Group Policy, Last seen, active modules, status).

## PARAMETERS

### Name

Filter active clients by hostname

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### ClientInfoId

Filter active clients by ClientInfoId

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
Get-HeimdalActiveClient -BaseUrl "https://dashboard.heimdalsecurity.com/api/heimdalapi"
```

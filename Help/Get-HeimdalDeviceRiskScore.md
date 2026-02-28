# Get-HeimdalDeviceRiskScore

## SYNOPSIS

Retrieves device risk scores from Heimdal Security API

## DESCRIPTION

This function retrieves a list of all available device risk scores from the Heimdal Security API.
The API endpoint is /activeclients and requires date range, and supports pagination.

This API endpoint retrieves information about the hardware specifications of an endpoint. This request works only when specifying the clientInfoId of an endpoint.
It does not list all endpoints in one request.

## PARAMETERS

### ClientInfoId

Filter devices by clientInfoId

- Type: String
- Required: true
- Accept pipeline input: false
- Accept wildcard characters: false

## EXAMPLES

### Example 1

```powershell
Get-HeimdalDeviceRiskScore -ClientInfoId "12345"
```

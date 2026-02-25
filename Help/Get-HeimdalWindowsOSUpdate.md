# Get-HeimdalWindowsOSUpdate

## SYNOPSIS

Retrieves OS updates from Heimdal Security API

## DESCRIPTION

This function connects to the Heimdal Security API and retrieves a list of OS updates for a specific device or group policy.
The API endpoint is /microsoftUpdates and requires customerId, date range, and supports pagination and filtering by clientInfoId, groupPolicyId, windowsUpdateStatus, severity, and category.

## PARAMETERS

### StartDate

The start date for filtering (format: YYYY-MM-DDTHH:MM:SS). Defaults to 30 days ago.

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### EndDate

The end date for filtering (format: YYYY-MM-DDTHH:MM:SS). Defaults to current date/time.

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### ClientInfoId

Optional filter to retrieve updates for a specific device (identified by clientInfoId)

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### GroupPolicyId

Optional filter to retrieve updates for devices under a specific group policy (identified by groupPolicyId)

This parameter wasn't tested successfully. perhaps the API doesn't support filtering by group policy, or
there are no updates associated with the specified group policy in the test environment.

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### WindowsUpdateStatus

Optional filter to retrieve updates based on their Windows Update status (e.g., "Pending", "Installed", "Failed")

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### Severity

Optional filter to retrieve updates based on their severity level (e.g., "Critical", "Important", "Moderate", "Low")

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

### Category

Optional filter to retrieve updates based on their category (e.g., "Security Updates", "Feature Updates", "Definition Updates")

- Type: String
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
Get-HeimdalWindowsOSUpdate -StartDate "2024-05-01T00:00:00" -EndDate "2024-06-01T23:59:59" -ClientInfoId "12345"
            This example retrieves OS updates for the device with clientInfoId "12345" that were reported between May 1, 2024 and June 1, 2024.
```

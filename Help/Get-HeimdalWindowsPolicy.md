# Get-HeimdalWindowsPolicy

## SYNOPSIS

Retrieves all group policies from Heimdal Security API

## DESCRIPTION

This function connects to the Heimdal Security API and retrieves a list of all group policies.
The API endpoint is /groupPolicy/getWindowsPolicies and requires customerId.

## PARAMETERS

### Id

(Optional) The ID of a specific group policy to retrieve. If not provided, all policies will be returned.

- Type: Int32
- Required: false
- Default value: 0
- Accept pipeline input: false
- Accept wildcard characters: false

### Name

(Optional) The name of a specific group policy to retrieve. If not provided, all policies will be returned.

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
```

### Example 2

```powershell
Get-HeimdalWindowsPolicy -Id 123
```

### Example 3

```powershell
Get-HeimdalWindowsPolicy -Name "PolicyName"
```

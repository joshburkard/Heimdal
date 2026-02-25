# Get-HeimdalLinuxPolicy

## SYNOPSIS

Retrieves Linux policies from Heimdal Security API

## DESCRIPTION

This function connects to the Heimdal Security API and retrieves a list of all Linux policies.
The API endpoint is /groupPolicy/getLinuxPolicies and requires customerId.

## PARAMETERS

### Id

(Optional) The ID of a specific Linux policy to retrieve. If not provided, all policies will be returned.

- Type: Int32
- Required: false
- Default value: 0
- Accept pipeline input: false
- Accept wildcard characters: false

### Name

(Optional) The name of a specific Linux policy to retrieve. If not provided, all policies will be returned.

- Type: String
- Required: false
- Accept pipeline input: false
- Accept wildcard characters: false

## EXAMPLES

### Example 1

```powershell
Get-HeimdalLinuxPolicy
```

### Example 2

```powershell
Get-HeimdalLinuxPolicy -Id 123
```

### Example 3

```powershell
Get-HeimdalLinuxPolicy -Name "PolicyName"
```

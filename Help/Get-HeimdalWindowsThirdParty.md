# Get-HeimdalWindowsThirdParty

## SYNOPSIS

Retrieves patch information from the Heimdal Security API.

## DESCRIPTION

This function connects to the Heimdal Security API and retrieves information about patches.
You can filter the results by providing a patch ID or patch name.

## PARAMETERS

### ClientInfoId

The ID of the client to retrieve third-party patch information for.

- Type: Int32
- Required: false
- Default value: 0
- Accept pipeline input: false
- Accept wildcard characters: false

### Status

Filter patches by status. Valid values are "latest", "update", "vulnerable", "patched", "uninstalled".

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
Get-HeimdalWindowsThirdParty -ClientInfoId 12345
```

### Example 2

```powershell
Get-HeimdalWindowsThirdParty -Status "vulnerable"
```

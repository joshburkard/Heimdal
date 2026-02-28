# Heimdal PowerShell Module

A PowerShell module for accessing the Heimdal Security API.

Unfortunattely, the Heimdal Security exposes currently only Read-Only activities to the API.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey)

## 📋 Table of Contents

## 🎯 Overview

The Heimdal PowerShell module provides functions to read settings and assets from the Heimdal Security API.

The module supports PowerShell 5.1 and 7.x.

## Requirements

- **PowerShell**: 5.1 or higher (tested with PowerShell 7.5.4)
- **Credentials**: A API Key and CustomerID with API access privileges
- **Network**: Access to the API URL [https://dashboard.heimdalsecurity.com/api/heimdalapi](https://dashboard.heimdalsecurity.com/api/heimdalapi)

## 📦 Installation

1. Clone or download the module to your PowerShell modules directory:

   ```powershell
   $ModulePath = Join-Path $PROFILE .. "Modules"
   git clone <repo-url> $ModulePath\Heimdal
   ```

2. Import the module:
   ```powershell
   Import-Module Heimdal
   ```

## 🚀 Quick Start

### Connect to MECM

```powershell
# Basic connection using current user credentials
Connect-Heimdal -ApiKey "ABCDEFG1234" -CustomerId "123456"
```

### Use Module Functions

Once connected with `Connect-Heimdal`, other module functions can use the stored connection:

```powershell
# Get device information
Get-HeimdalActiveClient -Name "COMPUTER01"
```

other functions will be described in the [Help](./Help/README.md) folder

## 📚 Available Functions

- [`Connect-Heimdal`](./Help/Connect-Heimdal.md) - Connects to the Heimdal API and save the connection settings for other functions
- [`Get-HeimdalActiveClient`](./Help/Get-HeimdalActiveClient.md) - Retrieves active clients from Heimdal Security API
- [`Get-HeimdalDeviceInfo`](./Help/Get-HeimdalDeviceInfo.md) - Retrieves device information from Heimdal Security API
- [`Get-HeimdalDeviceNotification`](./Help/Get-HeimdalDeviceNotification.md) - Retrieves device notifications from Heimdal Security API
- [`Get-HeimdalDeviceRiskScore`](./Help/Get-HeimdalDeviceRiskScore.md) - Retrieves device risk scores from Heimdal Security API
- [`Get-HeimdalLinuxPolicy`](./Help/Get-HeimdalLinuxPolicy.md) - Retrieves Linux policies from Heimdal Security API
- [`Get-HeimdalOSUpdate`](./Help/Get-HeimdalOSUpdate.md) - Retrieves OS updates from Heimdal Security API
- [`Get-HeimdalWindowsPolicy`](./Help/Get-HeimdalWindowsPolicy.md) - Retrieves all group policies from Heimdal Security API
- [`Invoke-HeimdalApiRequest`](./Help/Invoke-HeimdalApiRequest.md) - Helper to invoke Heimdal API requests with 429 retry logic.

## Architecture

The module follows this pattern:

```
Heimdal/
├── Code/                                    # Source code
│   ├── function-template.ps1                # Template for new functions
│   ├── Private/                             # Internal helper functions
│   │   └── Invoke-HeimdalApiRequest.ps1     # Core API interaction function
│   └── Public/                              # Exported module functions
│       ├── Connect-Heimdal.ps1
│       ├── Get-HeimdalActiveClient.ps1
│       ├── Get-HeimdalDeviceInfo.ps1
│       ├── Get-HeimdalCollection.ps1
│       └── ...                              # Other public functions
│
├── CI/                                      # Continuous Integration scripts
│   ├── Build-Module.ps1                     # Main build script
│   ├── Create-ModuleDocumentation.ps1       # Documentation generator
│   └── Module-Settings.json                 # Module metadata
│
├── Tests/                                   # Test files
│   ├── Functions.Tests.ps1                  # Structural tests (BLOCKING)
│   ├── Module.Tests.ps1                     # Module manifest tests
│   ├── Test-*.Tests.ps1                     # Functional tests per function
│   ├── TestHelpers.ps1                      # Shared test utilities
│   ├── declarations_sample.ps1              # Sample test configuration
│   └── declarations.ps1                     # Your test configuration (git-ignored)
│
├── Help/                                    # Generated markdown documentation
│   ├── Connect-Heimdal.md
│   ├── Get-HeimdalDevice.md
│   └── ...                                  # One file per function
│
├── Heimdal/                                 # Built module output
│   ├── 0.0.13/                              # Version folders
│   │   ├── Heimdal.psm1                     # Compiled module
│   │   └── Heimdal.psd1                     # Module manifest
│   └── ...                                  # Previous versions
│
├── Backup/                                  # Backup of previous builds
├── Examples/                                # Usage examples and scenarios
├── README.md                                # Main documentation
├── CHANGELOG.md                             # Version history
└── LICENSE                                  # MIT License
```
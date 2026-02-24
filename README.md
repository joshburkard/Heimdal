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
Get-HeimdalDevice -Name "COMPUTER01"
```

other functions will be described in the [Help](./Help/README.md) folder

## 📚 Available Functions

- [`Connect-Heimdal`](./Help/Connect-Heimdal.md) - Connects to the Heimdal API and save the connection settings for other functions
- [`Get-HeimdalDevice`](./Help/Get-HeimdalDevice.md) - Get Devices from the Heimdal API
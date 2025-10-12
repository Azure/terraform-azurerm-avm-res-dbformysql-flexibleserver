# Helper Scripts

This directory contains helper scripts for working with the module.

## setup-auth.sh

A helper script to verify and set up Azure authentication for local Terraform testing.

**Usage:**
```bash
./scripts/setup-auth.sh
```

**What it does:**
- Checks if Azure CLI is installed
- Verifies you're logged in to Azure
- Displays current subscription
- Allows you to switch subscriptions if needed
- Provides next steps for running tests

**Requirements:**
- Azure CLI installed
- Valid Azure subscription access

For more information about authentication and testing, see [../TESTING.md](../TESTING.md).

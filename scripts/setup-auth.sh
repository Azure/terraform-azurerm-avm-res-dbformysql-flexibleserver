#!/bin/bash
# Local Testing Helper Script
# This script helps set up and verify Azure authentication for local Terraform testing

set -e

echo "Azure Terraform Testing Setup"
echo "=============================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed"
    echo "   Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

echo "✓ Azure CLI is installed"

# Check if logged in
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure"
    echo "   Run: az login"
    exit 1
fi

echo "✓ Logged in to Azure"

# Display current subscription
SUBSCRIPTION=$(az account show --query name -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "   Current subscription: $SUBSCRIPTION"
echo "   Subscription ID: $SUBSCRIPTION_ID"
echo ""

# Ask if user wants to change subscription
read -p "Do you want to use this subscription? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Available subscriptions:"
    az account list --query "[].{Name:name, SubscriptionId:id}" -o table
    echo ""
    read -p "Enter subscription ID to use: " SUB_ID
    az account set --subscription "$SUB_ID"
    echo "✓ Switched to subscription: $(az account show --query name -o tsv)"
fi

echo ""
echo "Authentication Setup Complete!"
echo "=============================="
echo ""
echo "You can now run Terraform commands:"
echo "  cd examples/default"
echo "  terraform init"
echo "  terraform plan"
echo ""
echo "Or run AVM compliance checks:"
echo "  export PORCH_NO_TUI=1"
echo "  ./avm pre-commit"
echo ""

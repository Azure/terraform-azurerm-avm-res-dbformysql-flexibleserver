# Testing Guide

This document describes how to test this Terraform module and how Azure authentication works for different environments.

## Azure Authentication

The module uses the Azure Terraform provider (`azurerm`) which supports multiple authentication methods. The provider is configured in each example with:

```hcl
provider "azurerm" {
  features {}
}
```

This configuration automatically supports the following authentication methods (in order of precedence):

### 1. OpenID Connect (OIDC) - GitHub Actions

When running in GitHub Actions CI/CD, the workflow uses OIDC with federated identity credentials. The following environment variables are automatically set:

- `ARM_CLIENT_ID` - The Azure AD application (client) ID
- `ARM_TENANT_ID` - The Azure AD tenant ID  
- `ARM_SUBSCRIPTION_ID` - The Azure subscription ID
- `ARM_USE_OIDC=true` - Enables OIDC authentication
- `ARM_OIDC_REQUEST_TOKEN` - The OIDC token from GitHub
- `ARM_OIDC_REQUEST_URL` - The OIDC token request URL

The `.github/workflows/pr-check.yml` workflow uses a managed workflow from `Azure/avm-terraform-governance` that handles this automatically.

### 2. Azure CLI - Local Development

For local development and testing, the provider will use Azure CLI authentication if you're logged in:

```bash
# Login to Azure
az login

# Set the subscription (if you have multiple)
az account set --subscription "your-subscription-id"

# Verify authentication
az account show
```

Once logged in, you can run Terraform commands and the provider will use your Azure CLI credentials.

**Quick Setup**: Use the provided helper script:
```bash
./scripts/setup-auth.sh
```

This script will verify your Azure CLI setup and help you select the right subscription.

### 3. Service Principal - Alternative for Local/CI

You can also use Service Principal authentication by setting environment variables:

```bash
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="your-secret"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

### 4. Managed Identity - Azure Resources

When running on Azure resources (VM, Container Instance, etc.), the provider can use Managed Identity:

```bash
export ARM_USE_MSI=true
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

## Running Tests

### Prerequisites

- **Azure Subscription**: You need an active Azure subscription with appropriate permissions
- **Authentication**: Set up authentication using one of the methods above
- **Docker**: Required for running AVM tooling

### Local Testing with Examples

1. Navigate to an example directory:

```bash
cd examples/default
```

2. Ensure you're authenticated (see authentication methods above)

3. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

4. Clean up:

```bash
terraform destroy
```

### AVM Compliance Testing

The module uses Azure Verified Modules (AVM) governance tooling for compliance testing.

#### Pre-commit Checks

Before committing changes, run pre-commit checks:

```bash
export PORCH_NO_TUI=1
./avm pre-commit
```

This will:
- Run linting checks
- Format Terraform files
- Generate documentation
- Validate module structure

#### PR Checks

Before creating a PR, run the full PR check:

```bash
export PORCH_NO_TUI=1  
./avm pr-check
```

This runs all compliance checks including:
- Linting
- Well-architected framework validation
- Example validation

**Note**: The AVM tooling runs in a Docker container. If you encounter DNS or network issues, these tests are also run automatically in the GitHub Actions CI/CD pipeline where networking is properly configured.

### Testing in GitHub Actions

The CI/CD pipeline automatically runs all tests when you:
- Open a pull request
- Update a pull request
- Merge to main

The workflow uses OIDC authentication automatically - no secrets required.

## Test Examples

Each example in the `examples/` directory demonstrates different module features:

- **default**: Basic MySQL Flexible Server with high availability
- **ad-admin**: Server with Azure AD administrator
- **flexible-database**: Server with database configuration
- **private-endpoint**: Server with private endpoint connectivity
- **server-config**: Server with custom configuration parameters
- **flexible-server-with-firewall**: Server with firewall rules

## Troubleshooting

### Authentication Issues

If you get authentication errors:

1. Verify you're logged in: `az account show`
2. Check you have the right subscription: `az account list`
3. Verify your permissions in the Azure Portal

### DNS Issues with AVM Tooling

If you see DNS errors when running `./avm` commands locally, this is a known issue with the container networking. The tests will still run successfully in GitHub Actions where networking is properly configured.

### Region and High Availability

Not all Azure regions support zone-redundant high availability for MySQL Flexible Server. The examples use regions known to support this feature (e.g., "australiaeast", "westus3"). If you change the region, verify it supports the features you're using.

## Additional Resources

- [Azure Verified Modules Documentation](https://azure.github.io/Azure-Verified-Modules/)
- [AVM Terraform Testing Guide](https://azure.github.io/Azure-Verified-Modules/contributing/terraform/testing/)
- [Azure Provider Authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
- [GitHub OIDC with Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)

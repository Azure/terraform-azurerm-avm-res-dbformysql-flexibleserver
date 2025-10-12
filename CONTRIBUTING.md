# Contributing

This project welcomes contributions and suggestions. Most contributions require you to
agree to a Contributor License Agreement (CLA) declaring that you have the right to,
and actually do, grant us the rights to use your contribution. For details, visit
https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need
to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the
instructions provided by the bot. You will only need to do this once across all repositories using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Development and Testing

Before contributing, please review [TESTING.md](./TESTING.md) for information on:
- Setting up Azure authentication for local development
- Running tests and compliance checks
- Using the AVM governance tooling

### Quick Start

1. **Authenticate with Azure**:
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

2. **Make your changes** to the module code

3. **Run pre-commit checks**:
   ```bash
   export PORCH_NO_TUI=1
   ./avm pre-commit
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Your commit message"
   ```

5. **Run PR checks**:
   ```bash
   export PORCH_NO_TUI=1
   ./avm pr-check
   ```

6. **Create a pull request** following the PR template

For more details on testing and authentication, see [TESTING.md](./TESTING.md).

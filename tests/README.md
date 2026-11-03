# Tests

Run `avm test unit` for fully mocked MySQL version, encryption, identity, and private endpoint regression tests. No Azure credentials are required.

The version tests assert unchanged forwarding of `5.7`, `8.0.21`, and `8.4` to the server and preserve the omitted and explicit-null input contract without asserting an Azure-selected default from mock output. The default example continues to use `8.0.21`.

Run these tests with AzureRM 4.55.0 (the minimum supported provider). Mocked tests verify module wiring, not live Azure compatibility, regional version availability, or supported upgrade paths.

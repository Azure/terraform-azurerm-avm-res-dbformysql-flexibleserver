# Tests

Run `avm test unit` for fully mocked MySQL version, encryption, identity, and private endpoint regression tests. No Azure credentials are required.

The version tests assert unchanged forwarding of `5.7`, `8.0.21`, and `8.4` to the server and preserve the omitted and explicit-null input contract without asserting an Azure-selected default from mock output. A mocked apply of the default example verifies that its omitted version remains `8.0.21`.

Run these tests with AzureRM 4.55.0 (the minimum supported provider). Mocked tests verify module wiring, not live Azure compatibility, regional version availability, or supported upgrade paths.

To preserve the committed minimum-provider selections, initialize with `terraform init -backend=false -input=false -lockfile=readonly -test-directory=tests/unit`, then run `avm test unit --no-init`. Bare `avm test unit` initializes with provider upgrades and can update the lock file.

The private endpoint ASG tests cover both managed and unmanaged DNS zone groups. They use distinct endpoint IDs, multiple ASGs on one endpoint, and the same ASG map key on different endpoints to verify every association reaches the correct endpoint and ASG. Interface tests also assert that omitted endpoints or ASG maps create no associations.

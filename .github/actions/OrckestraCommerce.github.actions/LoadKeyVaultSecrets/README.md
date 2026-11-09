# Load Key Vault Secrets

Fetches one or more secrets from an Azure Key Vault and exposes them as environment variables for the remaining steps of the job. Authentication uses `azure/login` with OIDC (federated credentials) — no client secret is stored in GitHub. Secret values are masked in the logs by default; a value can be explicitly opted out of masking when it isn't actually sensitive.

This action runs `bash` and the Azure CLI directly on the runner (no Docker container), so it works on `ubuntu-latest`, `windows-latest`, and `macos-latest` GitHub-hosted runners, all of which have the Azure CLI preinstalled.

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `client-id` | true | | The client ID of the Azure App Registration (federated identity) used to authenticate via OIDC. |
| `tenant-id` | true | | The Azure AD tenant ID of the App Registration. |
| `subscription-id` | false | `''` | The Azure subscription ID. Not required to read secrets from Key Vault (a data-plane operation independent of subscription), but can be set to pin the CLI's active subscription context. |
| `vault-name` | true | | The name of the Azure Key Vault to read secrets from. |
| `secrets` | true | | Comma-separated list of secrets to fetch. See syntax below. |

### `secrets` syntax

Each comma-separated entry is one of:

| Entry | Effect |
| --- | --- |
| `name` | Fetches secret `name`, exposes it as env var `NAME` (uppercased, `-` replaced with `_`). Masked in logs. |
| `name:alias` | Fetches secret `name`, exposes it as env var `ALIAS` instead. Masked in logs. |
| `name!` | Same as `name`, but the value is **not** masked in logs. |
| `name:alias!` | Same as `name:alias`, but the value is **not** masked in logs. |

Example: `"cmp-username!, cmp-password, nuget-feed-token:NUGET_AUTH_TOKEN"`.

Only use `!` for values that aren't actually sensitive (e.g. a client/environment code) — once unmasked, the value appears in plaintext in the job's logs for the rest of the run.

## Required permissions

The calling job must grant the OIDC token permission, otherwise `azure/login` fails to authenticate:

```yaml
permissions:
  id-token: write
  contents: read
```

## Using the fetched secrets in later steps

The action writes the fetched values to `$GITHUB_ENV`, so they're available for the rest of the job:

- In a `run:` step: reference the plain environment variable, e.g. `$NUGET_AUTH_TOKEN` (bash) or `$env:NUGET_AUTH_TOKEN` (pwsh).
- As an input to another `uses:` step: reference the `env` context, e.g. `${{ env.NUGET_AUTH_TOKEN }}`.

## Example usage

```yaml
jobs:
  deployment:
    runs-on: windows-latest
    permissions:
      id-token: write   # Required for requesting the OIDC token
      contents: read    # Required for actions/checkout
    steps:
      - name: Load values from key vault
        uses: Harris-E-Commerce/OrckestraCommerce.github.actions/LoadKeyVaultSecrets@latest
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
          vault-name: "occ-deployment-kv"
          secrets: "cmp-client-code!, cmp-occ-start-environment-authtoken, cmp-username!, cmp-password"

      - name: Starting environment
        uses: Harris-E-Commerce/OrckestraCommerce.github.actions/StartStopEnvironment@latest
        with:
          cmpAuthToken: ${{ env.CMP_OCC_START_ENVIRONMENT_AUTHTOKEN }}
          cmpClientCode: ${{ env.CMP_CLIENT_CODE }}
          cmpEnvironment: ${{ vars.CMP_ENVIRONMENT }}
          operation: "Start"
```

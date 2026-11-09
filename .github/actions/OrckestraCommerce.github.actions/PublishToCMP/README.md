# Upload package (PublishToCMP)

Uploads deployment packages to a CMP (Cloud Management Platform) feed. This is a Windows composite action (requires Windows PowerShell 5.1, e.g. `runs-on: windows-latest`) that wraps the CMP package upload call, equivalent to the `PubCMP` Azure DevOps pipeline task.

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `cmpUrl` | true | `https://api.orckestra.cloud/` | Address of the CMP instance used to deploy the platform. |
| `cmpUsername` | true | | Username to authenticate to CMP. See [CMP connection documentation](https://docs.orckestra.com/developer-documentation/getting-started/setting-up-your-platform/undersanding-the-project-template/azure-devops-pipeline-tasks#cmp-connection). |
| `cmpPassword` | true | | Password to authenticate to CMP. |
| `cmpClientCode` | true | | The code of the client. |
| `cmpPackageFolder` | true | | Folder where to search for packages to upload to CMP. |
| `cmpStability` | false | | The CMP feed where packages are uploaded. One of `Develop`, `PreRelease`, `Release`. |
| `packagesList` | true | | Specifies which files to upload, one entry per line. Interpreted according to `packagesListFilterType`. See [packages filter syntax](https://docs.orckestra.com/developer-documentation/getting-started/setting-up-your-platform/undersanding-the-project-template/azure-devops-pipeline-tasks#pubcmp-packages-filter). |
| `packagesListFilterType` | true | `FilePattern` | The format used for each line of `packagesList`. One of `FilePattern`, `RegEx`. See [documentation](https://docs.orckestra.com/developer-documentation/getting-started/setting-up-your-platform/undersanding-the-project-template/azure-devops-pipeline-tasks#pubcmp-packages-filter-type). |
| `buildNumber` | true | | Build version compared against any "optional version target" specified in `packagesList`, in the format `\d+\.\d+.*`. Use `$(Build.BuildNumber)` in a release pipeline, `$(GitVersion.NuGetVersion)` in a build pipeline, or a hardcoded version if no build variable is available. This setting will be deprecated in the near future. |

## Example usage

```yaml
name: Publish OCC

on:
  workflow_dispatch:

jobs:
  publish:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Publish OCC
        uses: Harris-E-Commerce/OrckestraCommerce.github.actions/PublishToCMP@latest
        with:
          cmpUrl: ${{ vars.CMP_URL }}
          cmpUsername: ${{ vars.CMP_USERNAME }}
          cmpPassword: ${{ secrets.CMP_PASSWORD }}
          cmpClientCode: ${{ vars.CMP_CLIENT_CODE }}
          cmpEnvironment: ${{ vars.CMP_ENVIRONMENT }}
          cmpPackageFolder: '${{ github.workspace }}\packages'
          cmpStability: 'Develop'
          packagesList: |-
            OrckestraCommerce\.Notifications\..*\.nupkg
            OrckestraCommerce\.MobileStoreFulfillment\..*\.nupkg
          packagesListFilterType: 'RegEx'
          buildNumber: 6.6.6-alpha666
```

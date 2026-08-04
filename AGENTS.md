# AGENTS.md

This file provides guidance to AI coding agents working with code in this repository.

## What this repository is

This is **not** an application — it is an Orckestra Commerce Cloud (OCC) **Commerce Model**: the term Orckestra uses for a declarative dataset (JSON, SQL, XAML workflow files, HTML email templates) plus a small amount of .NET glue code, bundled into a NuGet package (`CommerceModel.BetterRetail.*.nupkg`) that provisions a tenant's commerce environment — stores, warehouses, catalogs, users, order-processing workflows, email templates, etc. — to seed/configure a sample retailer called "BetterRetail". Most of the "logic" in this repo is Commerce Model data, not executable code.

The dataset models several regional storefronts/scopes off a shared base: `Global`, `BetterRetailUSA`, `BetterRetailCanada`, `BetterRetailEuro`, `BetterRetailNorway`. Catalog data is versioned per scope (e.g. `BetterRetailUSA-Dev-v1.3`, `BetterRetailUSA-Catalog-v1.0`, `BetterRetailUSA-Qa-v1.0`).

## Build

Requires **Visual Studio 2022** (the `.sln` targets `VisualStudioVersion = 17.0.0.0` and `build/Build.psake.ps1` pins `$VisualStudioVersion = '2022'`) and **Windows PowerShell 5.1** (not PowerShell Core — the build script is not supported there).

Build from a PowerShell window in `build/`:

```powershell
.\Build.ps1 -t all -ExtraProperties @{ SensitiveData = @{ NewUsersPassword = '<PWD>' ; ShippoApiKey = '...'; TranssmartApiUsername = '...'; TranssmartApiPassword = '...'; TranssmartAccount = '...'; TranssmartApiEndpoint = '...'; AvalaraAccountNumber = '...' ; AvalaraCompanyCode = '...' ; AvalaraLicenceKey = '...' ; AvalaraServiceUrl = '...' ; DeliverySolutionsApiEndpoint = '...' ; DeliverySolutionsApiKey = '...' ; DeliverySolutionsTenantId = '...' ; DeliverySolutionsSecretKey = '...' } }
```

`NewUsersPassword` is the only required sensitive value; the rest can be omitted if you don't use Shippo/Transsmart/Avalara/DeliverySolutions. Instead of passing `-ExtraProperties` on the command line, you can create `build/build.sensitivedata.json` (git-ignored) with the same keys — `Build.psake.ps1`'s `Get-SensitiveData` will pick it up automatically.

`Build.ps1` is a thin wrapper around `build/Build.psake.ps1` (psake). Key psake tasks (`-t <task>`):
- `All` (default) → `Clean, Compile, Publish`
- `Compile` → restore, substitute sensitive-data tokens, stamp assembly/manifest version, build both `.csproj`s, generate the `.nupkg`, then **revert** the sensitive-data substitution (`UndoSensitiveData`)
- `Test` → runs xUnit via `Find-TestContainers`/`Invoke-XUnit`, but there is currently no test project in `CommerceModel.BetterRetail.sln`, so this is a no-op today
- NuGet auth: build prompts for and caches a PAT in the user env var `OrckestraAzureArtifactsPassword` on first run (required, since Orckestra/OCC packages come from a private feed via `nuget.config`).

Build output (`CommerceModel.BetterRetail.*.nupkg`) lands in `artifacts/Nuget/` and, on a dev machine, is also copied to `C:\Packages\` for local OCC installer consumption.

### Sensitive data / before committing

Several checked-in files contain `#TokenName#` placeholders (e.g. `#NewUsersPassword#`) that the `ReplaceSensitiveData` task swaps for real values during compile, and `UndoSensitiveData` swaps back afterward:
- `src/CommerceModel.BetterRetail/Parameters.All.xml`
- `src/CommerceModel.BetterRetail/artifacts/OOE/BetterRetail/CreateUsersActivity/users.json`
- `src/CommerceModel.BetterRetail/artifacts/OOE/BetterRetail/QueueOrderSchemaImportActivity/providers.json`
- `src/CommerceModel.BetterRetail/artifacts/OOE/BetterRetail/QueueFoundationSchemaImportActivity/providers.json`
- `src/CommerceModel.BetterRetail/artifacts/OOE/BetterRetail/QueueProfilesImportActivity/CUSTOMER.json`

If a build is interrupted before `UndoSensitiveData` runs, `git status`/`git diff` these files before committing — real credentials must never be committed in place of the `#Token#` placeholders.

## Deployment (context, not something to automate)

The built `.nupkg` is referenced from an OCC "desired installer"/desired-state file (either locally in an OCC dev install, or via Orckestra's Cloud Management Platform). `build/build-pipeline.yml` is the Azure DevOps pipeline: it builds with `Build.ps1 -TaskList All`, then (outside PR builds) publishes the package to CMP for both the `occ` and `sls` client codes via the `PublishToCMP@1` task. See `README.md` for the full manual deployment walkthrough (variable groups, desired-state JSON, `LoadDataProfile_DevTest` activity parameters) — it's detailed and not duplicated here.

## Versioning / branching

Versioning is handled by `Orckestra.Versioning` (a psake-invoked semver-from-git tool), configured in `.semver-git.json`: every branch matching `version/<Major>.<Minor>` is a mainline branch for that version line (e.g. `version/5.8`, `version/5.10` are each independently maintained). The `Manifest.json` `DependsOnPackages` versions and the `OrckestraCommerce.*` package references in `CommerceModel.BetterRetail.csproj` (`Packages/NuGet/OrckestraCommerce.*.5.10.0/...`) should stay aligned with the branch's target OCC version — e.g. on `version/5.10`, dependencies point at `5.10.0` OCC packages.

## Architecture

Two compiled C# projects, both targeting **.NET Framework 4.8**:

- **`src/CommerceModel.BetterRetail`** — the package itself.
  - `Plugin.cs` implements `IPlugin` and registers `BetterRetailDamProvider` (`DamProviders/BetterRetailDamProvider.cs`, `IDamProvider`) as OCC's DAM (digital asset management) provider — it just formats CDN image URLs from a fixed template, no real asset storage.
  - `LoadDataProfile_DevTest.xaml` is the orchestration entry point: a Windows Workflow Foundation `Activity` (compiled, referenced by fully-qualified name in deployment tooling as `CommerceModel.BetterRetail.LoadDataProfile_DevTest, CommerceModel.BetterRetail`) that sequences dozens of `TaskActivity` steps — via the `oct:`/`octc:`/`octc1:`/`octf:`/`octh:`/`octn:`/`octp:`/`octp1:`/`octs:` XAML namespaces — from `OrckestraCommerce.CommerceModelUtilities` (stores, warehouses, users, catalogs, profiles, search, email templates, HTML document templates, SQL scripts, etc.) plus the two custom activities below.
    - **This repo only supplies the data those activities read — it does not implement them.** The actual `TaskActivity` code for every `oct*:` namespace lives in a separate checkout of the OCC platform monorepo, under `Source/Features/CommerceModelUtilities` (e.g. `../OrckestraCommerce/Source/Features/CommerceModelUtilities` if that repo is checked out as a sibling of this one) — see that folder's own `AGENTS.md` for what each activity does with the input folder it's pointed at. Despite its name, `CommerceModelUtilities` holds no Commerce Model data itself; it's generic provisioning logic that any Commerce Model's workflow (like this one) calls into.
  - `Manifest.json` declares the package name/version, `DependsOnPackages` (OCC core/marketing packages this model requires), and `ModifiesComponents` (`DB-OLTP`, `OOE`, `OCS-CM`, `OCS-CD` — the OCC components this package writes data into).
  - `artifacts/` holds the actual import payloads, organized by **target OCC component**, then by **activity name**, then by **scope/version folder**. Each `TaskActivity` in `LoadDataProfile_DevTest.xaml` reads from a same-named subfolder at deploy time. Examples:
    - `artifacts/OOE/BetterRetail/QueueProductCatalogsImportsActivity/<Scope>-<Env>-v<N>/*.json` — catalog/category/price/product/relation data per scope+version.
    - `artifacts/OOE/BetterRetail/CreateStoresActivity/<Scope>/`, `CreateWarehousesActivity/<Scope>/` — per-scope store/warehouse definitions.
    - `artifacts/OOE/BetterRetail/ImportEmailTemplatesActivity/Global/<TemplateName>/Contents/{Html,Text}/<culture>.{html,txt}` — transactional email templates (order lifecycle, returns, recurring orders) per culture.
    - `artifacts/OOE/BetterRetail/ExecuteSQLScriptActivity/<Database>/*.sql` and `CustomExecuteSQLScriptActivity/`, `BetterRetailExecuteSQLScriptActivity/` — raw SQL run against specific OCC databases (Order, Membership, Product, Foundation).
    - `artifacts/OOE/App_Data/Workflows/Orders/<Scope|Global>/*.xaml` — the actual **order-processing workflows** (cart checkout, submit order, order totals, post-processing) deployed per scope, with `Global` as the fallback/default when a scope doesn't override one. `CopyArtifacts.targets` copies these (plus the compiled workflow assembly) into the package output for both OOE and OCS at build time.
    - `artifacts/BlobStorage/{bopisfulfillmentprovider,shipfromstorefulfillmentprovider}/<Scope>/` — seed blobs for the pickup/ship-from-store fulfillment providers.
    - `artifacts/Solr/schema.all.xml`, `artifacts/OCS-OOE/Search/` — search indexing schema/config.
  - When changing store behavior (fulfillment, pricing, checkout), check both the relevant `*.xaml` workflow under `App_Data/Workflows/Orders/<Scope>` **and** whether `Global` needs the same change for scopes that don't override it.

- **`src/CommerceModel.BetterRetail.Activities`** — custom Workflow Foundation `TaskActivity` implementations (async, using Orckestra's `Orckestra.Overture.DurableTask` model) referenced from `LoadDataProfile_DevTest.xaml` via the `cba:` XAML namespace:
  - `BetterRetailExecuteSQLScriptActivity` / `CustomExecuteSQLScriptActivity` — walk a folder tree under the deployed assembly location (named after `{CommerceModelName}\{ActivityTypeName}\{DatabaseName}\*.sql`) and execute each `.sql` file in order against the matching OCC database, used for schema tweaks that must run before/alongside the standard import activities.
  - `SetAdditionnalLineItemAttributesActivity` — a custom line-item attribute setter used by the order workflows.

- **`src/Common/GlobalAssemblyInfo.cs`** — shared assembly metadata linked into both projects; version/copyright fields here are rewritten by the build (`InitializeAssemblyVersion`, `InitializeMetadata` psake tasks) and should not be hand-edited for versioning purposes.

There are no automated tests in this repository today (no test project in the `.sln`); the `Test` psake task exists but has nothing to run.

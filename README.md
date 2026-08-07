# Liquibase POC for SQL Server promotion

This workspace contains a small proof-of-concept for promoting a database schema from development to test with Liquibase while keeping the process repeatable, auditable, and easy to automate.

## What this POC demonstrates

- A shared changelog that creates a baseline schema.
- Environment-specific Liquibase property files for dev, test, and stage.
- Context-based changesets so test-only seeds can be applied when needed.
- A simple promotion script that applies schema to test and optionally seeds test from stage.
- A local SQL Server container so the flow can be exercised end to end.

## Repository layout

- [changelogs/](changelogs/) – Liquibase change logs and SQL files.
- [config/](config/) – environment-specific Liquibase property files.
- [scripts/](scripts/) – helper scripts for setup, migration, and promotion.
- [docker-compose.yml](docker-compose.yml) – local SQL Server container.

## Prerequisites

- Docker Desktop
- Liquibase CLI installed and available on your PATH
- SQL Server JDBC driver jar available to Liquibase

## Quick start

1. Start SQL Server:
   ```powershell
   docker compose up -d
   ```
   This requires Docker Desktop with working virtualization support on Windows.

2. Create the databases:
   ```powershell
   sqlcmd -S localhost,1433 -U sa -P 'YourStrong!Passw0rd' -i .\scripts\init-databases.sql
   ```

3. Apply the baseline schema to development:
   ```powershell
   .\scripts\run-liquibase.ps1 -ConfigFile .\config\dev.properties
   ```

4. Promote the schema to test:
   ```powershell
   .\scripts\promote-to-test.ps1 -SeedFromStage
   ```

5. Optional: run the same promotion flow again to validate repeatability:
   ```powershell
   .\scripts\promote-to-test.ps1
   ```

6. Or run the full sequence in one step:
   ```powershell
   .\scripts\run-poc.ps1
   ```

7. To target a remote SQL Server instead of localhost, update the relevant config file with:
   ```powershell
   .\scripts\set-env.ps1 -Environment test -Server 'your-sql-server.database.windows.net,1433' -Database 'liquibase_test' -Username 'yourUser' -Password 'yourPassword'
   ```

The promotion script first applies the Liquibase changelog to the test database and then, when requested, runs the stage-to-test seed script to keep the test environment aligned with a known stage snapshot.

## How the promotion flow works

- The shared changelog applies the base schema and reference data.
- Test-only seed data is wrapped in a Liquibase context so it only runs for the test environment.
- The promotion script updates the test database with the same changelog and can optionally run a data seed script from stage.

## Notes

- Update the connection details in the property files to match your environment.
- If you are using a different SQL Server image or port, adjust the Docker and Liquibase settings accordingly.
- The seed-from-stage script is intentionally simple and should be adapted to your actual staging tables and business rules.

## Continuous Integration (example)

This repository includes a sample GitHub Actions workflow at `.github/workflows/liquibase-ci.yml` that demonstrates how to run the POC in CI:

- The workflow starts a SQL Server service container in the runner.
- It waits for the server to become available and then runs Liquibase using the official Docker image.
- The workflow runs `update` against `dev` and (on push) runs the `test` and `stage` updates and a simple seed step.

To enable CI for your team, push this repo to GitHub and open a pull request; the workflow will run automatically on `main`.

If you prefer another CI system (Azure Pipelines, Jenkins, GitLab CI), the same steps map directly: start a SQL Server container, wait for readiness, run Liquibase against the target config files, and optionally run the stage-to-test seed step.

## Validation script

After running the promotion, use the included validation script to assert the `test` database schema and basic data are present:

```powershell
# run the validation script (may need ExecutionPolicy bypass)
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-Location 'D:\liquibase project'; .\scripts\validate-promotion.ps1"
```

The script checks that `dbo.Customers` and `dbo.Orders` exist in `liquibase_test` and reports row counts.

**Overview**

This document explains how the Liquibase POC works and how the automated pipeline runs so you can present it to the team.

**Components**
- **SQL Server container:** `mcr.microsoft.com/mssql/server:2022-latest` used locally and in CI as the database under test.
- **Liquibase changelogs:** `changelogs/master.xml` and SQL changesets (`001-*.sql`, `002-*.sql`, `003-*.sql`) are the source-of-truth.
- **Config files:** `config/dev.properties`, `config/stage.properties`, `config/test.properties` control connection targets.
- **Scripts:** helper scripts in `scripts/` (e.g., `run-liquibase.ps1`, `promote-to-test.ps1`, `validate-promotion.ps1`, `run-demo.ps1`).
- **CI workflow:** `.github/workflows/demo-ci.yml` runs the end-to-end demo automatically.

**High-level flow (what happens in a demo run)**
1. Start SQL Server (local `docker compose up -d` or GitHub Actions `services.mssql`).
2. Create databases using `scripts/init-databases.sql`.
3. Apply Liquibase changes to `dev` (liquibase update against `dev.properties`).
4. Apply Liquibase changes to `stage` (liquibase update against `stage.properties`).
5. Promote to `test` by running Liquibase with context `test` (applies test-only changesets).
6. Optionally seed `liquibase_test` from stage using `sqlcmd` and `scripts/seed-test-from-stage.sql`.
7. Run validation (`scripts/validate-promotion.ps1`) to confirm expected tables and row counts.

**How automation runs in CI**
- Trigger: the workflow runs on pushes to changelogs/scripts/config or via manual `workflow_dispatch`.
- Secrets: set repository secret `SA_PASSWORD` (used by the SQL Server service and `sqlcmd`).
- Service: GitHub Actions runs a SQL Server container as a `services` entry; the job waits for the service healthcheck.
- Liquibase execution: by default the workflow runs Liquibase in a Docker container (`liquibase/liquibase:4.31.1`), but you can pass `liquibase_image` or set `use_runner=true` to install/run the CLI on the runner.
- Seeding/validation: `sqlcmd` is installed on the runner to run the seed SQL and validate counts. The workflow fails if validation does not match expected values.

**How to explain the pipeline to the team (short script)**
- "We keep our schema and seeds in Liquibase changelogs. The pipeline runs those changelogs in order against dev and stage, then promotes the same audited changes to test. We seed test from stage using idempotent SQL, then run a validation step that asserts expected rows exist. The CI workflow runs all these steps automatically using a disposable SQL Server service and fails the job if validation fails — so we get repeatable, auditable schema promotions."

**Demo talking points / slides bullets**
- Environment parity: same DB image and change scripts run locally and in CI.
- Audited migrations: every change is a Liquibase changeset (id, author) and recorded in `DATABASECHANGELOG`.
- Repeatability: `liquibase update` is idempotent; CI recreates a clean service for each run.
- Safe promotion: test gets the same changes + controlled seed from stage; validation ensures data integrity.

**Common troubleshooting notes**
- If Liquibase fails, confirm Java 17 is available (the included `run-liquibase.ps1` forces `JAVA_HOME` if needed).
- `sqlcmd` SSL errors: use `-C` to trust container certs (already used in helper scripts).
- Docker on Windows: ensure Docker Desktop is running with WSL2 backend; if needed set `DOCKER_HOST='npipe:////./pipe/dockerDesktopLinuxEngine'`.

**Where to look in the repo**
- Workflow file: `.github/workflows/demo-ci.yml`
- Demo runner: `scripts/run-demo.ps1`
- Promotion script: `scripts/promote-to-test.ps1`
- Validation: `scripts/validate-promotion.ps1`

**One-line run commands for demo**
```powershell
Set-Location 'D:\liquibase project'
# Local interactive demo
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ".\scripts\run-demo.ps1"

# Trigger CI manually: Actions → Demo CI (or use workflow_dispatch inputs: liquibase_image, use_runner)
```

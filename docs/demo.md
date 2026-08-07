**Quick Demo**

- **Goal:** Run a short end-to-end POC that shows schema promotion dev→stage→test and optional seeding of test from stage.
- **Prereqs:** Docker Desktop (WSL2), PowerShell, `sqlcmd` (mssql-tools) on PATH, Liquibase CLI or use provided docker image.

Run the interactive demo from the repo root:

```powershell
Set-Location 'D:\liquibase project'
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ".\scripts\run-demo.ps1"
```

What the script does:
- Starts required containers via `docker compose up -d`
- Waits for SQL Server to be ready
- Creates databases (`init-databases.sql`)
- Runs dev and stage changelogs (via included scripts)
- Promotes to `test` and seeds test from stage
- Runs validation checks that confirm tables and row counts in `liquibase_test`

Notes:
- If your environment requires a Docker named-pipe host, set `DOCKER_HOST` before running, e.g.:

```powershell
$env:DOCKER_HOST = 'npipe:////./pipe/dockerDesktopLinuxEngine'
```

For CI, run the same steps in a job using secrets for `SA_PASSWORD` and the Liquibase Docker image.

CI setup
- Add repository secret `SA_PASSWORD` with a strong value (matches local default `YourStrong!Passw0rd` only for testing).
- The included GitHub Actions workflow is at `.github/workflows/demo-ci.yml` and will:
	- start a SQL Server service container
	- run Liquibase updates against `dev`, `stage`, `test`
	- seed `test` from `stage`
	- validate expected row counts

Trigger the demo CI manually from the Actions tab or by pushing changes to changelogs, `scripts/`, or `config/`.

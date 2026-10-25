# One-shot: creates CI workflow, pushes to your GitHub repo, then sets up venv.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# 1. CI workflow
New-Item -ItemType Directory -Force .github\workflows | Out-Null
@'
name: CI
on:
  push:
    branches: [main]
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: pip
      - run: pip install -r requirements.txt
      - name: Lint
        run: ruff check .
      - name: Tests with coverage
        run: pytest --cov=src --cov-report=term-missing
'@ | Set-Content -Encoding utf8 .github\workflows\ci.yml

# 2. Push to your repo
git remote set-url origin https://github.com/2026a1c100075-droid/taxi-forecasting-mlops.git
git add .
git status --short
git commit -m "Capstone: add CI workflow, golden-path script, README"
git push -u origin main
Write-Host "`nPUSHED. Commit:" -ForegroundColor Green
git log -1 --oneline

# 3. Environment (skip if it already exists)
if (-not (Test-Path .venv)) { py -3.11 -m venv .venv }
.\.venv\Scripts\python.exe -m pip install -r requirements.txt

Write-Host "`nSetup done. Now run:  .\run_all.ps1" -ForegroundColor Green

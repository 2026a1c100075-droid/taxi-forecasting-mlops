# Golden path: runs every stage end to end from a clean checkout.
# Prereq: py -3.11 -m venv .venv ; .\.venv\Scripts\python.exe -m pip install -r requirements.txt
$ErrorActionPreference = "Stop"
$py = ".\.venv\Scripts\python.exe"

function Step($name, [scriptblock]$cmd) {
    Write-Host "`n=== $name ===" -ForegroundColor Cyan
    & $cmd
    if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $name" -ForegroundColor Red; exit 1 }
    Write-Host "OK: $name" -ForegroundColor Green
}

Step "1. Tests"                 { & $py -m pytest -q }
Step "2. Data pipeline"         { & $py -m scripts.run_pipeline --year 2024 --month 1 }
Step "3. Model training"        { & $py -m scripts.train_models --n-trials 1 }
Step "4. Batch inference"       { & $py -m scripts.batch_forecast --horizon 3 }
Step "5. Drift detection"       { & $py -m scripts.monitoring.demo_drift_report --problem all --mode drift }
Step "6. Responsible AI"        { & $py -m scripts.responsible.run_analysis }

Write-Host "`nALL STAGES COMPLETE" -ForegroundColor Green
Write-Host "Next: start API  -> $py -m uvicorn src.serving.api:app --port 8000"
Write-Host "      dashboard  -> $py -m streamlit run dashboard/app.py"

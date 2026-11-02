# HW10 helper: runs the whole Kubernetes homework locally and records the evidence.
#
# What it does: downloads the 2026 course files (05-deployment and 10-kubernetes), checks the model checksum,
# builds the image, calls the API in a container (Q1), creates a kind cluster, loads the image, applies the three
# manifests, calls the API through a port-forward (Q7 check), reads the HPA and deletes the cluster.
# Output: hw10_results.json and hw10_log.txt in the folder where you run it.
#
# Run from an EMPTY folder that contains only this script, with Docker Desktop open:
#   powershell -ExecutionPolicy Bypass -File .\run_hw10_kubernetes.ps1
# Optional: add -KeepCluster to leave the cluster running (delete it later with: kind delete cluster --name mlzoomcamp-2026)

param([switch]$KeepCluster)

$ErrorActionPreference = "Continue"
$raw = "https://raw.githubusercontent.com/DataTalksClub/machine-learning-zoomcamp/main/cohorts/2026/homework"
$image = "zoomcamp-model:2026-hw10"
$cluster = "mlzoomcamp-2026"
$ctx = "kind-$cluster"
$container = "hw10api"
$results = [ordered]@{}
$root = (Get-Location).Path
$clusterTouched = $false

Start-Transcript -Path (Join-Path $root "hw10_log.txt") -Force | Out-Null

function Stop-Here($message) { throw $message }
function Get-File($url, $out) {
    if (-not (Test-Path $out)) {
        Write-Host "downloading $out ..."
        curl.exe -fL -s -S -o $out $url
        if ($LASTEXITCODE -ne 0) { Stop-Here "download failed: $url" }
    }
}
function Call-Api($url) {
    # same request as 05-deployment/q6_test.py
    $payload = '{"lead_source":"organic_search","industry":"technology","employment_status":"employed","location":"europe","number_of_courses_viewed":4,"annual_income":80304.0,"interaction_count":7,"lead_score":0.74}'
    $payloadFile = Join-Path ([System.IO.Path]::GetTempPath()) "hw10_payload_q6.json"   # absolute path, independent of the current folder
    [System.IO.File]::WriteAllText($payloadFile, $payload, (New-Object System.Text.UTF8Encoding($false)))
    for ($i = 1; $i -le 15; $i++) {
        $body = curl.exe -s --max-time 30 -X POST $url -H "Content-Type: application/json" -d "@$payloadFile"
        if ($LASTEXITCODE -eq 0 -and $body) { return ($body | ConvertFrom-Json) }
        Start-Sleep -Seconds 3
    }
    return $null
}

try {
    # ---- 0. prerequisites (Q2) ----
    Write-Host "`n== 0. Prerequisites =="
    docker info *> $null
    if ($LASTEXITCODE -ne 0) { Stop-Here "Docker is not running. Open Docker Desktop and wait for 'Engine running'." }
    if (-not (Get-Command kind -ErrorAction SilentlyContinue)) { Stop-Here "kind is not installed. Install it with: winget install Kubernetes.kind  (then open a new PowerShell window)" }
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) { Stop-Here "kubectl is not installed. Install it with: winget install Kubernetes.kubectl  (then open a new PowerShell window)" }
    $results["kind_version"] = (kind --version | Out-String).Trim()
    $results["kubectl_client_version"] = (kubectl version --client | Out-String).Trim()
    Write-Host $results["kind_version"]
    Write-Host $results["kubectl_client_version"]

    # ---- 1. files ----
    Write-Host "`n== 1. Course files =="
    New-Item -ItemType Directory -Force -Path "05-deployment", "10-kubernetes" | Out-Null
    foreach ($f in "Dockerfile", "model.py", "predict.py", "feature_defaults.json", "model_metadata.json", "pipeline.bin", "q6_test.py", "pyproject.toml", "uv.lock", ".python-version") {
        Get-File "$raw/05-deployment/$f" "05-deployment/$f"
    }
    foreach ($f in "deployment.yaml", "service.yaml", "hpa.yaml") { Get-File "$raw/10-kubernetes/$f" "10-kubernetes/$f" }
    $sha = (Get-FileHash -Algorithm SHA256 "05-deployment/pipeline.bin").Hash.ToLower()
    $results["pipeline_sha256"] = $sha
    if ($sha -ne "1646bbdcd38d4f044da6b630c5b332c93a314245a8c21929011c42de51f629f1") { Stop-Here "pipeline.bin checksum differs from the one used in the analysis: $sha. Do not continue; send me hw10_log.txt." }
    Write-Host "OK  pipeline.bin  $($sha.Substring(0,16))..."

    # ---- 2. build + Q1 ----
    Write-Host "`n== 2. Build the image and call the API in a container (Q1) =="
    Push-Location "05-deployment"
    docker build -t $image .
    $buildExit = $LASTEXITCODE
    Pop-Location
    if ($buildExit -ne 0) { Stop-Here "docker build failed" }
    if (docker ps -aq --filter "name=^$container$") { docker rm -f $container | Out-Null }   # remove a leftover container, if any
    docker run -d --rm --name $container -p 9696:9696 $image | Out-Null
    if ($LASTEXITCODE -ne 0) { Stop-Here "docker run failed (is port 9696 already in use?)" }
    $q1 = Call-Api "http://localhost:9696/predict"
    docker stop $container *> $null
    if (-not $q1) { Stop-Here "no answer from the API in the container" }
    $results["q1_response"] = $q1
    Write-Host "Q1 response: $($q1 | ConvertTo-Json -Compress)"

    # ---- 3. cluster ----
    Write-Host "`n== 3. Create the kind cluster =="
    $existing = (kind get clusters 2>$null | Out-String)
    if ($existing -match [regex]::Escape($cluster)) { $clusterTouched = $true; Write-Host "cluster $cluster already exists, reusing it" }
    else {
        $clusterTouched = $true
        kind create cluster --name $cluster
        if ($LASTEXITCODE -ne 0) { Stop-Here "kind create cluster failed" }
    }
    kubectl cluster-info --context $ctx

    Write-Host "`n== 4. Services (Q4) =="
    $svc = (kubectl get services --context $ctx | Out-String).Trim()
    Write-Host $svc
    $results["services_default"] = $svc

    Write-Host "`n== 5. Load the image into the cluster (Q5) =="
    kind load docker-image $image --name $cluster
    if ($LASTEXITCODE -ne 0) { Stop-Here "kind load docker-image failed" }

    # ---- 4. deploy ----
    Write-Host "`n== 6. Deployment (Q6) =="
    Push-Location "10-kubernetes"
    kubectl apply -f deployment.yaml --context $ctx
    kubectl rollout status deployment/subscription --timeout=180s --context $ctx
    $rollout = $LASTEXITCODE
    $results["pods"] = (kubectl get pods --context $ctx | Out-String).Trim()
    Write-Host $results["pods"]
    if ($rollout -ne 0) {
        $results["pod_describe"] = (kubectl describe pods -l app=subscription --context $ctx | Out-String)
        Pop-Location
        Stop-Here "the deployment did not become ready in 180s (see pod_describe in hw10_results.json)"
    }

    Write-Host "`n== 7. Service (Q7) =="
    kubectl apply -f service.yaml --context $ctx
    $results["service"] = (kubectl get service subscription --context $ctx | Out-String).Trim()
    Write-Host $results["service"]

    Write-Host "`n== 8. Call the API through a port-forward =="
    $pf = Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "service/subscription", "9696:80", "--context", $ctx -PassThru -NoNewWindow
    Start-Sleep -Seconds 5
    $q7 = Call-Api "http://localhost:9696/predict"
    if ($pf -and -not $pf.HasExited) { Stop-Process -Id $pf.Id -Force }
    if (-not $q7) { Pop-Location; Stop-Here "no answer through the port-forward" }
    $results["q7_response"] = $q7
    Write-Host "Q7 response: $($q7 | ConvertTo-Json -Compress)"

    Write-Host "`n== 9. HPA (Q8) =="
    kubectl apply -f hpa.yaml --context $ctx
    Start-Sleep -Seconds 5
    $results["hpa"] = (kubectl get hpa subscription-hpa --context $ctx | Out-String).Trim()
    Write-Host $results["hpa"]
    Pop-Location

    $results["q1_vs_q7_difference"] = [math]::Abs($q1.conversion_probability - $q7.conversion_probability)
    $results["status"] = "ok"
}
catch {
    Write-Host "STOP: $_" -ForegroundColor Red
    $results["error"] = "$_"
}
finally {
    if ((-not $KeepCluster) -and $clusterTouched) {
        Write-Host "`n== Clean up =="
        kind delete cluster --name $cluster
    }
    ($results | ConvertTo-Json -Depth 5) | Set-Content -Encoding UTF8 (Join-Path $root "hw10_results.json")
    Stop-Transcript | Out-Null
}
Write-Host "`nDone. Send me hw10_results.json and hw10_log.txt."

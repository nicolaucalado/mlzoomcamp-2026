# HW9 helper: downloads the course files, checks SHA-256, builds and runs the Lambda container,
# invokes it and saves the response.
# Run from an EMPTY folder that contains only this script:
#   powershell -ExecutionPolicy Bypass -File .\run_hw9_container.ps1
$ErrorActionPreference = "Stop"

$prefix = "https://github.com/alexeygrigorev/large-datasets/releases/download/hairstyle"
$course = "https://raw.githubusercontent.com/DataTalksClub/machine-learning-zoomcamp/main/cohorts/2026/homework/09-serverless"
$sampleUrl = "https://habrastorage.org/webt/yf/_d/ok/yf_dokzqy3vcritme8ggnzqlvwa.jpeg"
$image = "mlzoomcamp-2026-serverless"
$name = "hw9lambda"

function Get-File($url, $out) {
    if (-not (Test-Path $out)) {
        Write-Host "downloading $out ..."
        curl.exe -fL -s -S -A "Mozilla/5.0" -o $out $url
        if ($LASTEXITCODE -ne 0) { throw "download failed: $url" }
    }
}
function Test-Hash($file, $expected) {
    $actual = (Get-FileHash -Algorithm SHA256 $file).Hash.ToLower()
    if ($actual -ne $expected) { throw "checksum mismatch for $file : $actual" }
    Write-Host "OK  $file  $($actual.Substring(0,16))..."
}

# 1. files
foreach ($f in "lambda_function.py", "Dockerfile", "requirements-lambda.txt", "smoke_test.py") { Get-File "$course/$f" $f }
Get-File "$prefix/hair_classifier_v1.onnx" "hair_classifier_v1.onnx"
Get-File "$prefix/hair_classifier_v1.onnx.data" "hair_classifier_v1.onnx.data"
Get-File $sampleUrl "sample.jpeg"

# 2. integrity
Test-Hash "hair_classifier_v1.onnx" "2b1adcb51745b73609ac7efebf3b6199483a931ed6dfe35ab925978f4357c2d8"
Test-Hash "hair_classifier_v1.onnx.data" "6ba88582d6098a535f918d9a56ad23800f919ad7bd5aad67e5b2bb3e289e5a7e"
Test-Hash "sample.jpeg" "6b3ae4003b5b6d54b51ee4d5fc5f183126bb1be0bf7066e5a846785fdcbfd2f5"

# 3. build
docker build -t $image .
if ($LASTEXITCODE -ne 0) { throw "docker build failed" }

# 4. run, invoke, stop
& { $ErrorActionPreference = "Continue"; docker rm -f $name 2>$null | Out-Null }
docker run -d --rm --name $name -p 9000:8080 $image | Out-Null
if ($LASTEXITCODE -ne 0) { throw "docker run failed (is port 9000 in use?)" }
try {
    $payload = '{"image_url":"' + $sampleUrl + '"}'
    [System.IO.File]::WriteAllText("$PWD\payload.json", $payload, (New-Object System.Text.UTF8Encoding($false)))
    $ok = $false
    for ($i = 1; $i -le 10; $i++) {
        Start-Sleep -Seconds 4
        curl.exe -s --max-time 120 -X POST "http://localhost:9000/2015-03-31/functions/function/invocations" `
            -H "Content-Type: application/json" -d "@payload.json" -o container_response.json
        if ($LASTEXITCODE -eq 0 -and (Test-Path container_response.json) -and ((Get-Item container_response.json).Length -gt 0)) { $ok = $true; break }
        Write-Host "container not ready yet (attempt $i), retrying ..."
    }
    if (-not $ok) { throw "no response from the container" }
    Write-Host ""
    Write-Host "RESPONSE:"
    Get-Content container_response.json
    Write-Host ""
    docker images $image
}
finally {
    & { $ErrorActionPreference = "Continue"; docker stop $name 2>$null | Out-Null }
}
Write-Host ""
Write-Host "Done. Send me sample.jpeg and container_response.json."

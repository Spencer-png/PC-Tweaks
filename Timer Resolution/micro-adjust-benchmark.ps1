param(
    [double]$INCREMENT = 0.002,
    [double]$START = 0.5,
    [double]$END = 0.8,
    [int]$SAMPLES = 20
)

function Is-Admin() {
    $current_principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $current_principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function main() {
    if (-not (Is-Admin)) {
        Write-Host "error: administrator privileges required"
        return 1
    }

    $iterations = ($END - $START) / $INCREMENT
    $total_ms = $iterations * 102 * $SAMPLES

    Write-Host "Approximate worst-case estimated time for completion: $([math]::Round($total_ms / 6E4, 2))mins"
    Write-Host "Worst-case is determined by assuming Sleep(1) = ~2ms with 1ms Timer Resolution"
    Write-Host "Start: $($START)ms, End: $($END)ms, Increment: $($INCREMENT)ms, Samples: $($SAMPLES)"

    Stop-Process -Name "SetTimerResolution" -ErrorAction SilentlyContinue

    Set-Location $PSScriptRoot

    foreach ($dependency in @("SetTimerResolution.exe", "MeasureSleep.exe")) {
        if (-not (Test-Path $dependency)) {
            Write-Host "error: $($dependency) not exists in current directory"
            return 1
        }
    }

    "RequestedResolutionMs,DeltaMs,STDEV" | Out-File results.txt

    for ($i = $START; $i -le $END; $i += $INCREMENT) {
        $i = [math]::Round($i, 3)

        Write-Host "info: benchmarking $($i)ms"

        Start-Process ".\SetTimerResolution.exe" -ArgumentList @("--resolution", ($i * 1E4), "--no-console")

        # unexpected results if there isn't a small delay after setting the resolution
        Start-Sleep 1

        $output = .\MeasureSleep.exe --samples $SAMPLES
        $outputLines = $output -split "`n"

        foreach ($line in $outputLines) {
            $avg_match = $line -match "Avg: (.*)"
            $stdev_match = $line -match "STDEV: (.*)"

            if ($avg_match) {
                $avg = $matches[1] -replace "Avg: "
            } elseif ($stdev_match) {
                $stdev = $matches[1] -replace "STDEV: "
            }
        }

        "$($i), $([math]::Round([double]$avg, 3)), $($stdev)" | Out-File results.txt -Append

        Stop-Process -Name "SetTimerResolution" -ErrorAction SilentlyContinue
    }

    Write-Host "info: results saved in results.txt"
    return 0
}

exit main

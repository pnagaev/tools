#Requires -RunAsAdministrator

$report = "$env:TEMP\DiskReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$drive  = 'C:\'

# Проверка наличия diskusage
if (-not (Get-Command diskusage -ErrorAction SilentlyContinue)) {
    Write-Error "diskusage not found. Install: https://www.outsidethebox.ms/tag/diskusage/"
    exit 1
}

Write-Host "Collecting data, please wait..." -ForegroundColor Cyan

$sections = [ordered]@{
    'REPORT DATE'        = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    'SOURCE'             = 'https://www.outsidethebox.ms/tag/diskusage/'
    'TOP 30 DIRECTORIES' = diskusage $drive /TopDirectory=30 /humanReadable 2>&1
    'SYSTEM FILES TOP 15'= diskusage /systemFile:15 /humanReadable 2>&1
    'ALLOCATION REPORT'  = fsutil volume allocationreport ($drive.TrimEnd('\')) 2>&1
}

# Сборка отчёта одним проходом
$output = foreach ($key in $sections.Keys) {
    "=" * 60
    "[$key]"
    ""
    $sections[$key]
    ""
}

$output | Out-File -FilePath $report -Encoding UTF8

Write-Host "Report saved: $report" -ForegroundColor Green

# Открыть в notepad явно, не через ассоциацию
notepad.exe $report

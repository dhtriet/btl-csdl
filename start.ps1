$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

$phpCommand = Get-Command php -ErrorAction SilentlyContinue
$phpExe = if ($phpCommand) { $phpCommand.Source } else {
    $wingetPhp = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Filter php.exe -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match 'PHP\.PHP\.' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    $wingetPhp.FullName
}

if (-not $phpExe) {
    Write-Error 'Khong tim thay PHP. Cai PHP 8+ hoac them php.exe vao PATH truoc khi chay.'
    exit 1
}

Write-Host 'Nexus: http://127.0.0.1:8000'
& $phpExe -S 127.0.0.1:8000 -t public

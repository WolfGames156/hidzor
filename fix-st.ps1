Write-Host "[1] Steam kontrol ediliyor..." -ForegroundColor White

function Ensure-SteamStopped {
    $attempt = 0

    while (Get-Process steam -ErrorAction SilentlyContinue) {
        $attempt++
        Write-Host "[!] Steam hâlâ çalışıyor (Deneme $attempt) → zorla kapatılıyor..." -ForegroundColor Yellow

        Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Sleep -Seconds 2

        if ($attempt -ge 5) {
            Write-Host "[X] Steam kapatılamadı. İşlem iptal edildi." -ForegroundColor Red
            exit 1
        }
    }

    Write-Host "[✓] Steam tamamen kapalı." -ForegroundColor Green
}

if (Get-Process steam -ErrorAction SilentlyContinue) {
    Write-Host "[2] Steam çalışıyor → kapatma işlemi başlatıldı..." -ForegroundColor Yellow
    Ensure-SteamStopped
} else {
    Write-Host "[2] Steam zaten kapalı." -ForegroundColor Green
}

Write-Host "[3] steam.run komutu çalıştırılıyor..." -ForegroundColor Cyan

irm steam.run | iex

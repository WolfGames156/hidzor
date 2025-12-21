Clear-Host

# -------------------- ADMIN CHECK (IEX SAFE) --------------------

$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$isAdmin   = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Eğer admin değilsek
if (-not $isAdmin) {

    Write-Host "Administrator yetkisi gerekli. Yeniden başlatılıyor..." -ForegroundColor Yellow

    # Script memory'de mi çalışıyor? (iwr | iex)
    if (-not $PSCommandPath) {

        # Temp'e script yaz
        $tempScript = Join-Path $env:TEMP "SteamDowngrader_Admin.ps1"
        $scriptText = $MyInvocation.MyCommand.ScriptBlock.ToString()
        Set-Content -Path $tempScript -Value $scriptText -Encoding UTF8

        # Admin olarak yeniden çalıştır
        Start-Process powershell.exe `
            -Verb RunAs `
            -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempScript`""

        exit
    }

    # Normal .ps1 dosyasıysa
    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""

    exit
}

# ----------------------------------------------------



Write-Host "===============================================================" -ForegroundColor DarkYellow
Write-Host "Steam 32-bit Recovery / Lock Script" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor DarkYellow
Write-Host ""

# -------------------- FUNCTIONS --------------------

function Get-SteamPath {
    $paths = @(
        "HKCU:\Software\Valve\Steam",
        "HKLM:\Software\Valve\Steam",
        "HKLM:\Software\WOW6432Node\Valve\Steam"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            $props = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
            foreach ($key in "SteamPath", "InstallPath") {
                if ($props.$key -and (Test-Path $props.$key)) {
                    return $props.$key
                }
            }
        }
    }
    return $null
}

function Download-FileWithProgress {
    param($Url, $OutFile)

    $wc = New-Object System.Net.WebClient
    $wc.DownloadProgressChanged += {
        param($s, $e)
        $bar = "=" * [math]::Floor($e.ProgressPercentage / 2)
        $bar = $bar.PadRight(50)
        Write-Host "`r  Progress: [$bar] $($e.ProgressPercentage)% " -NoNewline -ForegroundColor Cyan
    }
    $wc.DownloadFileCompleted += { Write-Host "" }

    $wc.DownloadFileAsync($Url, $OutFile)
    while ($wc.IsBusy) { Start-Sleep -Milliseconds 100 }
}

# -------------------- STEP 0 --------------------

Write-Host "Step 0: Locating Steam..." -ForegroundColor Yellow
$steamPath = Get-SteamPath

if (-not $steamPath) {
    Write-Host "Steam not found." -ForegroundColor Red
    exit
}

$steamExe = Join-Path $steamPath "Steam.exe"
Write-Host "Steam Path: $steamPath" -ForegroundColor Green
Write-Host ""

# -------------------- STEP 1 --------------------

Write-Host "Step 1: Killing Steam processes..." -ForegroundColor Yellow
Get-Process steam* -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2
Write-Host "Steam stopped." -ForegroundColor Green
Write-Host ""

# -------------------- STEP 2 --------------------

Write-Host "Step 2: Forcing Steam Fix ..." -ForegroundColor Yellow

$updateArgs = @(
    "-forcesteamupdate"
    "-forcepackagedownload"
    "-overridepackageurl http://web.archive.org/web/20251122131734if_/media.steampowered.com/client"
    "-exitsteam"
)

Start-Process `
    -FilePath $steamExe `
    -ArgumentList $updateArgs `
    -WorkingDirectory $steamPath `
    -Wait `
    -NoNewWindow

Write-Host "Forced update completed." -ForegroundColor Green
Write-Host ""

# -------------------- STEP 3 --------------------

Write-Host "Step 3: Creating steam.cfg (update lock)..." -ForegroundColor Yellow

$cfgPath = Join-Path $steamPath "steam.cfg"

Set-Content -Path $cfgPath -Value "BootStrapperInhibitAll=enable" -Encoding ASCII
Add-Content -Path $cfgPath -Value "BootStrapperForceSelfUpdate=disable" -Encoding ASCII

Write-Host "steam.cfg created." -ForegroundColor Green
Write-Host ""
Clear-Host

# -------------------- STEP 4 --------------------

Write-Host "Step 4: Launching Steam..." -ForegroundColor Yellow
Start-Process -FilePath $steamExe -ArgumentList "-clearbeta"
Write-Host "Steam launched." -ForegroundColor Green
Write-Host ""

# ASCII Art
Write-Host ""
Write-Host '                 _...Q._' -ForegroundColor Cyan
Write-Host '               .''       ''.' -ForegroundColor Cyan
Write-Host '              /           \' -ForegroundColor Cyan
Write-Host '             ;.-""--.._ |' -ForegroundColor Cyan
Write-Host '            /''-._____..-''\|' -ForegroundColor Cyan
Write-Host '          .'' ;  o   o    |`;' -ForegroundColor Cyan
Write-Host '         /  /|   ()      ;  \' -ForegroundColor Cyan
Write-Host '    _.-, ''-'' ; ''.__.-''    \  \' -ForegroundColor Cyan
Write-Host '.-"`,  |      \_         / `''`' -ForegroundColor Cyan
Write-Host ' ''._`.; ._    / `''--.,_=-;_' -ForegroundColor Cyan
Write-Host '    \ \|  `\ .\_     /`  \ `._' -ForegroundColor Cyan
Write-Host '     \ \    `/  ``---|    \   (~' -ForegroundColor Cyan
Write-Host '      \ \.  | o   ,   \    (~ (~  ______________' -ForegroundColor Cyan
Write-Host '       \ \`_\ _..-''    \  (\(~   |.------------.|' -ForegroundColor Cyan
Write-Host '        \/  ``        / \(~/     || ALL DONE!! ||' -ForegroundColor Cyan
Write-Host '         \__    __..-'' -   ''.    || """"  """" ||' -ForegroundColor Cyan
Write-Host '          \ \```             \   || discord.gg ||' -ForegroundColor Cyan
Write-Host '          ;\ \o               ;  || SYS_0xA7   ||' -ForegroundColor Cyan
Write-Host '          | \ \               |  ||____________||' -ForegroundColor Cyan
Write-Host '          ;  \ \              ;  ''------..------''' -ForegroundColor Cyan
Write-Host '           \  \ \ _.-''\      /          ||' -ForegroundColor Cyan
Write-Host '            ''. \-''     \   .''           ||' -ForegroundColor Cyan
Write-Host '           _.-"  ''      \-''           .-||-.' -ForegroundColor Cyan
Write-Host '           \ ''  '' ''      \           ''..---.- ''' -ForegroundColor Cyan
Write-Host '            \  '' ''      _.'' ' -ForegroundColor Cyan
Write-Host '             \'' ''   _.-''' -ForegroundColor Cyan
Write-Host '              \ _.-''' -ForegroundColor Cyan
Write-Host '               `' -ForegroundColor Cyan
Write-Host ""


# Pause before closing
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

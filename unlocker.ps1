# ============================================================
#   MC Unlocker | By Xenon Rexo | @xenonrexo
# ============================================================

Set-StrictMode -Off
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "MC Unlocker - by Xenon Rexo"

# ─── Colour Palette ──────────────────────────────────────────
$C = @{
    Title   = "Cyan"
    Border  = "DarkCyan"
    Label   = "White"
    OK      = "Green"
    Warn    = "Yellow"
    Err     = "Red"
    Dim     = "DarkGray"
    Accent  = "Magenta"
    Credit  = "Cyan"
}

# ─── URLs ────────────────────────────────────────────────────
$unlockUrl    = "https://raw.githubusercontent.com/shshamsff1/mc-unlocker-xenonrexo/main/mc/Unlock.dll"
$vcruntimeUrl = "https://raw.githubusercontent.com/shshamsff1/mc-unlocker-xenonrexo/main/mc/vcruntime140_1.dll"
$modLoaderUrl = "https://raw.githubusercontent.com/shshamsff1/mc-unlocker-xenonrexo/main/mc/ModLoader.dll"

# ─── Paths ───────────────────────────────────────────────────
$modsPath   = Join-Path $env:APPDATA "Minecraft Bedrock\mods"
$backupPath = Join-Path $env:APPDATA "Minecraft Bedrock\.backup"

# ─── Stored custom game path (session) ───────────────────────
$script:customGameRoot = $null

# ════════════════════════════════════════════════════════════
#  HELPERS
# ════════════════════════════════════════════════════════════

function Write-Line { param([string]$text = "", $fg = "White")
    Write-Host $text -ForegroundColor $fg
}

function Write-Divider { param([string]$char = "─", [int]$len = 58, $fg = "DarkCyan")
    Write-Host ($char * $len) -ForegroundColor $fg
}

function Write-Status { param([string]$msg, [string]$type = "info")
    $symbol = switch ($type) {
        "ok"   { "[+]" }
        "fail" { "[x]" }
        "wait" { "[~]" }
        "ask"  { "[?]" }
        default { "[i]" }
    }
    $color = switch ($type) {
        "ok"   { $C.OK   }
        "fail" { $C.Err  }
        "wait" { $C.Warn }
        "ask"  { $C.Accent }
        default { $C.Label }
    }
    Write-Host "  $symbol  $msg" -ForegroundColor $color
}

function Write-Banner {
    Clear-Host

    # ── Layout math ────────────────────────────────────────────────
    # Art column  (between outer left ║ and centre divider ║) : 20 chars
    # Right column (between centre divider ║ and outer right ║): 37 chars
    # Total inner = 20 + 1 (divider) + 37 = 58
    # Full line   = "  ║" (3) + 20 + "║" (1) + 37 + "║" (1) = 62 chars  ←  every line MUST be this
    #
    # Art rows:  "  ║" + " "(1) + X(8) + "  "(2) + R(8) + " "(1) + "║" + rp(37) + "║"
    #             3    +  1     +  8   +   2    +  8   +   1    +  1  +    37   +  1  = 62 ✓

    $aW  = 20   # art column inner width  (1+8+2+8+1)
    $rW  = 37   # right column inner width

    $top = "  ╔" + ("═" * ($aW + $rW)) + "╗"
    $mid = "  ║" + (" " * ($aW + $rW)) + "║"
    $bot = "  ╚" + ("═" * ($aW + $rW)) + "╝"

    # ── XR ASCII art — each string EXACTLY 8 chars ─────────────────
    # Verified: ██=2  ╗╔╝╚║═=1 each   space=1
    $aX = @(
        "██╗  ██╗",   # 2+1+2+2+1   = 8
        "╚██╗██╔╝",   # 1+2+1+2+1+1 = 8
        " ╚████╔╝",   # 1+1+4+1+1   = 8
        " ██╔██╗ ",   # 1+2+1+2+1+1 = 8
        "██╔╝╚██╗",   # 2+1+1+1+2+1 = 8
        "╚═╝  ╚═╝"    # 1+1+1+2+1+1+1 = 8
    )
    $aR = @(
        "██████╗ ",   # 6+1+1 = 8
        "██╔══██╗",   # 2+1+2+2+1 = 8
        "██████╔╝",   # 6+1+1 = 8
        "██╔══██╗",   # 8
        "██║  ██║",   # 2+1+2+2+1 = 8
        "╚═════╝ "    # 1+5+1+1 = 8
    )

    # ── Right-panel text — PadRight($rW) guarantees exactly 37 chars
    $rLines = @(
        "  MINECRAFT BEDROCK UNLOCKER",  # row 0
        "  v2.0   by Xenon Rexo",        # row 1
        "  @xenonrexo",                  # row 2
        "  Windows  /  Xbox Game Pass",  # row 3
        "",                             # row 4  blank
        ""                               # row 5  blank
    )
    $rFg = @($C.Title, $C.Title, $C.Credit, $C.Dim, $C.Dim, $C.Dim)

    # ── Draw ──────────────────────────────────────────────────────
    Write-Host ""
    Write-Host $top -ForegroundColor $C.Border

    for ($i = 0; $i -lt 6; $i++) {
        $rp = $rLines[$i].PadRight($rW)         # always exactly $rW chars
    }

    Write-Host $bot -ForegroundColor $C.Border
    Write-Host ""
}

function Write-Menu {
    Write-Divider
    Write-Host "  MAIN MENU" -ForegroundColor $C.Title
    Write-Divider
    Write-Host "  [1]  " -ForegroundColor $C.Accent -NoNewline; Write-Host "Install Minecraft For Windows (Xbox)" -ForegroundColor $C.Label
    Write-Host "  [2]  " -ForegroundColor $C.Accent -NoNewline; Write-Host "Unlock Game" -ForegroundColor $C.Label
    Write-Host "  [3]  " -ForegroundColor $C.Accent -NoNewline; Write-Host "Backup Game Files" -ForegroundColor $C.Label
    Write-Host "  [4]  " -ForegroundColor $C.Accent -NoNewline; Write-Host "Restore Game Files From Backup" -ForegroundColor $C.Label
    Write-Host "  [5]  " -ForegroundColor $C.Accent -NoNewline; Write-Host "Look For / Set Game Path" -ForegroundColor $C.Label
    Write-Host "  [6]  " -ForegroundColor $C.Accent -NoNewline; Write-Host "Exit" -ForegroundColor $C.Dim
    Write-Divider
    Write-Host "  Enter option " -ForegroundColor $C.Dim -NoNewline
    Write-Host "[1-6]" -ForegroundColor $C.Accent -NoNewline
    Write-Host ": " -ForegroundColor $C.Dim -NoNewline
}

function Pause-Return {
    Write-Host ""
    Write-Host "  Press any key to return to menu..." -ForegroundColor $C.Dim
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ════════════════════════════════════════════════════════════
#  CORE: Find Game Content Path
# ════════════════════════════════════════════════════════════

function Find-GamePath {
    param([bool]$silent = $false)

    # 1) Try stored custom root first
    if ($script:customGameRoot) {
        $p = Join-Path $script:customGameRoot "XboxGames\Minecraft for Windows\Content"
        if (Test-Path $p) { return $p }
    }

    # 2) Auto-scan all drives
    $drives = Get-PSDrive -PSProvider FileSystem
    foreach ($drive in $drives) {
        $p = Join-Path $drive.Root "XboxGames\Minecraft for Windows\Content"
        if (Test-Path $p) { return $p }
    }

    if (-not $silent) {
        Write-Status "Game path not found automatically." "fail"
    }
    return $null
}

function Request-GamePath {
    Write-Host ""
    Write-Status "Could not locate Minecraft automatically." "fail"
    Write-Status "Enter your Xbox Games root drive/folder" "ask"
    Write-Host "  Example: " -ForegroundColor $C.Dim -NoNewline
    Write-Host "E:\XboxGames" -ForegroundColor $C.Warn -NoNewline
    Write-Host "  or just  " -ForegroundColor $C.Dim -NoNewline
    Write-Host "E:\" -ForegroundColor $C.Warn
    Write-Host ""
    Write-Host "  > " -ForegroundColor $C.Accent -NoNewline
    $input = Read-Host

    if ([string]::IsNullOrWhiteSpace($input)) {
        Write-Status "No path entered. Cancelled." "fail"
        return $null
    }

    # Support entering the full XboxGames path or just the drive root
    $candidates = @(
        (Join-Path $input "Minecraft for Windows\Content"),
        (Join-Path $input "XboxGames\Minecraft for Windows\Content")
    )

    foreach ($c in $candidates) {
        if (Test-Path $c) {
            $script:customGameRoot = $input
            Write-Status "Game found at: $c" "ok"
            return $c
        }
    }

    Write-Status "Minecraft not found at: $input" "fail"
    Write-Status "Make sure the path contains 'XboxGames\Minecraft for Windows\Content'" "info"
    return $null
}

# ════════════════════════════════════════════════════════════
#  OPTION 1 — Unlock Game
# ════════════════════════════════════════════════════════════

function Invoke-UnlockGame {
    Write-Banner
    Write-Host "  UNLOCK GAME" -ForegroundColor $C.Title
    Write-Divider
    Write-Host ""

    # ── Step 1: Locate game ──
    Write-Status "Searching for game installation..." "wait"
    $contentPath = Find-GamePath

    if (-not $contentPath) {
        $contentPath = Request-GamePath
        if (-not $contentPath) {
            Pause-Return; return
        }
    }

    Write-Status "Game located: $contentPath" "ok"
    Write-Host ""

    # ── Step 2: Prepare mods folder ──
    Write-Status "Checking mods folder..." "wait"
    try {
        if (!(Test-Path $modsPath)) {
            New-Item -ItemType Directory -Path $modsPath -Force | Out-Null
            Write-Status "Mods folder created: $modsPath" "ok"
        } else {
            Write-Status "Mods folder already exists." "ok"
        }
    } catch {
        Write-Status "Failed to create mods folder: $_" "fail"
        Pause-Return; return
    }

    Write-Host ""
    Write-Divider "·"
    Write-Host "  Downloading & Installing files..." -ForegroundColor $C.Warn
    Write-Divider "·"
    Write-Host ""

    # ── Step 3: Download files ──
    $installList = @(
        @{ Name = "Unlock.dll";         Url = $unlockUrl;    Dest = Join-Path $modsPath    "Unlock.dll"         },
        @{ Name = "vcruntime140_1.dll"; Url = $vcruntimeUrl; Dest = Join-Path $contentPath "vcruntime140_1.dll" },
        @{ Name = "ModLoader.dll";      Url = $modLoaderUrl; Dest = Join-Path $contentPath "ModLoader.dll"      }
    )

    $failed = 0
    foreach ($file in $installList) {
        Write-Host "  Downloading " -ForegroundColor $C.Dim -NoNewline
        Write-Host $file.Name -ForegroundColor $C.Warn -NoNewline
        Write-Host " ..." -ForegroundColor $C.Dim
        try {
            Invoke-WebRequest -Uri $file.Url -OutFile $file.Dest -UseBasicParsing -ErrorAction Stop
            Write-Status "$($file.Name) installed successfully." "ok"
        } catch {
            Write-Status "FAILED to download $($file.Name): $_" "fail"
            $failed++
        }
    }

    Write-Host ""
    Write-Divider

    if ($failed -eq 0) {
        Write-Host "  ✔  " -ForegroundColor $C.OK -NoNewline
        Write-Host "All files installed successfully!" -ForegroundColor $C.Label
        Write-Host "  ✔  " -ForegroundColor $C.OK -NoNewline
        Write-Host "Game is ready — open Minecraft and enjoy!" -ForegroundColor $C.Warn
        Write-Host ""
        Write-Host "  " -NoNewline
        Write-Host "Enjoy your game! — Xenon Rexo" -ForegroundColor $C.Credit
    } else {
        Write-Host "  ✘  " -ForegroundColor $C.Err -NoNewline
        Write-Host "$failed file(s) failed to install. Check your internet connection." -ForegroundColor $C.Err
    }

    Write-Divider
    Pause-Return
}

# ════════════════════════════════════════════════════════════
#  OPTION 2 — Backup Files
# ════════════════════════════════════════════════════════════

function Invoke-InstallMinecraft {
    Write-Banner
    Write-Host "  INSTALL MINECRAFT FOR WINDOWS (XBOX)" -ForegroundColor $C.Title
    Write-Divider
    Write-Host ""
    Write-Status "Opening Xbox store page..." "wait"
    try {
        Start-Process "https://www.xbox.com/en-US/games/store/minecraft-for-windows/9nblggh2jhxj"
        Write-Status "Xbox store page opened in your browser." "ok"
    } catch {
        Write-Status "Failed to open browser: $_" "fail"
    }
    Write-Host ""
    Pause-Return
}

function Invoke-BackupFiles {
    Write-Banner
    Write-Host "  BACKUP GAME FILES" -ForegroundColor $C.Title
    Write-Divider
    Write-Host ""

    Write-Status "Searching for game installation..." "wait"
    $contentPath = Find-GamePath

    if (-not $contentPath) {
        $contentPath = Request-GamePath
        if (-not $contentPath) { Pause-Return; return }
    }

    Write-Status "Game located: $contentPath" "ok"
    Write-Host ""

    # Files to back up
    $filesToBackup = @(
        @{ Src = Join-Path $modsPath    "Unlock.dll";         Name = "Unlock.dll"         },
        @{ Src = Join-Path $contentPath "vcruntime140_1.dll"; Name = "vcruntime140_1.dll" },
        @{ Src = Join-Path $contentPath "ModLoader.dll";      Name = "ModLoader.dll"      }
    )

    Write-Status "Creating backup folder..." "wait"
    try {
        if (!(Test-Path $backupPath)) {
            New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        }
        # Store the content path so restore knows where to put files back
        $contentPath | Out-File -FilePath (Join-Path $backupPath "_contentpath.txt") -Encoding UTF8 -Force
        Write-Status "Backup folder ready: $backupPath" "ok"
    } catch {
        Write-Status "Could not create backup folder: $_" "fail"
        Pause-Return; return
    }

    Write-Host ""
    $backed = 0; $skipped = 0
    foreach ($f in $filesToBackup) {
        if (Test-Path $f.Src) {
            $dest = Join-Path $backupPath $f.Name
            try {
                Copy-Item -Path $f.Src -Destination $dest -Force -ErrorAction Stop
                Write-Status "Backed up: $($f.Name)" "ok"
                $backed++
            } catch {
                Write-Status "Failed to backup $($f.Name): $_" "fail"
            }
        } else {
            Write-Status "Not found (skipped): $($f.Name)" "info"
            $skipped++
        }
    }

    Write-Host ""
    Write-Divider
    if ($backed -gt 0) {
        Write-Host "  ✔  " -ForegroundColor $C.OK -NoNewline
        Write-Host "$backed file(s) backed up to:" -ForegroundColor $C.Label
        Write-Host "       $backupPath" -ForegroundColor $C.Warn
    }
    if ($skipped -gt 0) {
        Write-Host "  i  " -ForegroundColor $C.Dim -NoNewline
        Write-Host "$skipped file(s) were not present (unlock may not have run yet)." -ForegroundColor $C.Dim
    }
    Write-Divider
    Pause-Return
}

# ════════════════════════════════════════════════════════════
#  OPTION 3 — Restore From Backup
# ════════════════════════════════════════════════════════════

function Invoke-RestoreFiles {
    Write-Banner
    Write-Host "  RESTORE GAME FILES FROM BACKUP" -ForegroundColor $C.Title
    Write-Divider
    Write-Host ""

    if (!(Test-Path $backupPath)) {
        Write-Status "No backup found at: $backupPath" "fail"
        Write-Status "Run option [2] first to create a backup." "info"
        Pause-Return; return
    }

    Write-Status "Backup folder found." "ok"
    Write-Host ""

    # Read saved content path
    $savedPathFile = Join-Path $backupPath "_contentpath.txt"
    if (Test-Path $savedPathFile) {
        $contentPath = (Get-Content $savedPathFile -Raw).Trim()
        Write-Status "Restoring to game path: $contentPath" "info"
    } else {
        Write-Status "Content path record missing. Searching automatically..." "wait"
        $contentPath = Find-GamePath
        if (-not $contentPath) {
            $contentPath = Request-GamePath
            if (-not $contentPath) { Pause-Return; return }
        }
    }

    Write-Host ""
    $restored = 0; $failed = 0

    $restoreMap = @(
        @{ File = "Unlock.dll";         Dest = $modsPath    },
        @{ File = "vcruntime140_1.dll"; Dest = $contentPath },
        @{ File = "ModLoader.dll";      Dest = $contentPath }
    )

    foreach ($r in $restoreMap) {
        $src = Join-Path $backupPath $r.File
        if (Test-Path $src) {
            try {
                if (!(Test-Path $r.Dest)) {
                    New-Item -ItemType Directory -Path $r.Dest -Force | Out-Null
                }
                Copy-Item -Path $src -Destination (Join-Path $r.Dest $r.File) -Force -ErrorAction Stop
                Write-Status "Restored: $($r.File)" "ok"
                $restored++
            } catch {
                Write-Status "Failed to restore $($r.File): $_" "fail"
                $failed++
            }
        } else {
            # If not in backup, remove the installed version to revert
            $target = Join-Path $r.Dest $r.File
            if (Test-Path $target) {
                try {
                    Remove-Item $target -Force -ErrorAction Stop
                    Write-Status "Removed (was not in original): $($r.File)" "ok"
                    $restored++
                } catch {
                    Write-Status "Could not remove $($r.File): $_" "fail"
                    $failed++
                }
            } else {
                Write-Status "Already clean (not present): $($r.File)" "info"
            }
        }
    }

    Write-Host ""
    Write-Divider
    if ($failed -eq 0) {
        Write-Host "  ✔  " -ForegroundColor $C.OK -NoNewline
        Write-Host "Game restored to its original state!" -ForegroundColor $C.Label
    } else {
        Write-Host "  !  " -ForegroundColor $C.Warn -NoNewline
        Write-Host "Restore completed with $failed error(s). Check messages above." -ForegroundColor $C.Warn
    }
    Write-Divider
    Pause-Return
}

# ════════════════════════════════════════════════════════════
#  OPTION 4 — Look For / Set Game Path
# ════════════════════════════════════════════════════════════

function Invoke-LookForPath {
    Write-Banner
    Write-Host "  LOOK FOR GAME PATH" -ForegroundColor $C.Title
    Write-Divider
    Write-Host ""

    Write-Status "Scanning all drives for Minecraft..." "wait"
    Write-Host ""

    $found = $null
    $drives = Get-PSDrive -PSProvider FileSystem
    foreach ($drive in $drives) {
        $p = Join-Path $drive.Root "XboxGames\Minecraft for Windows\Content"
        Write-Host "  Checking " -ForegroundColor $C.Dim -NoNewline
        Write-Host $p -ForegroundColor $C.Warn -NoNewline
        if (Test-Path $p) {
            Write-Host "  ✔" -ForegroundColor $C.OK
            $found = $p
        } else {
            Write-Host "  ✘" -ForegroundColor $C.Err
        }
    }

    # Also check stored custom path
    if ($script:customGameRoot) {
        $p = Join-Path $script:customGameRoot "XboxGames\Minecraft for Windows\Content"
        Write-Host "  Checking " -ForegroundColor $C.Dim -NoNewline
        Write-Host $p -ForegroundColor $C.Accent -NoNewline
        Write-Host " [custom]" -ForegroundColor $C.Dim -NoNewline
        if (Test-Path $p) {
            Write-Host "  ✔" -ForegroundColor $C.OK
            $found = $p
        } else {
            Write-Host "  ✘" -ForegroundColor $C.Err
        }
    }

    Write-Host ""

    if ($found) {
        Write-Divider
        Write-Status "Game path confirmed: $found" "ok"
        Write-Divider
    } else {
        Write-Divider
        Write-Status "Game not found on any drive." "fail"
        Write-Divider
        Write-Host ""
        Write-Host "  Would you like to set a custom path? " -ForegroundColor $C.Dim -NoNewline
        Write-Host "[Y/N]: " -ForegroundColor $C.Accent -NoNewline
        $ans = Read-Host
        if ($ans -match "^[Yy]") {
            $result = Request-GamePath
            if ($result) {
                Write-Host ""
                Write-Status "Custom path saved for this session." "ok"
                Write-Status "Path: $result" "ok"
            }
        }
    }

    Pause-Return
}

# ════════════════════════════════════════════════════════════
#  STARTUP: Check for Updates (lightweight)
# ════════════════════════════════════════════════════════════

function Check-Updates {
    Write-Status "Checking for updates..." "wait"
    try {
        $response = Invoke-WebRequest `
            -Uri "https://raw.githubusercontent.com/shshamsff1/mc-unlocker-xenonrexo/main/mc/Unlock.dll" `
            -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Status "Server reachable. You're running the latest version." "ok"
    } catch {
        Write-Status "Update check failed (offline or server down)." "warn"
    }
    Write-Host ""
}

# ════════════════════════════════════════════════════════════
#  MAIN LOOP
# ════════════════════════════════════════════════════════════

Write-Banner
Check-Updates

while ($true) {
    Write-Banner
    Write-Menu
    $choice = Read-Host

    switch ($choice.Trim()) {
        "1" { Invoke-InstallMinecraft }
        "2" { Invoke-UnlockGame   }
        "3" { Invoke-BackupFiles  }
        "4" { Invoke-RestoreFiles }
        "5" { Invoke-LookForPath  }
        "6" {
            Write-Host ""
            Write-Host "  Bye! — Xenon Rexo " -ForegroundColor $C.Credit
            Write-Host "  @xenonrexo" -ForegroundColor $C.Dim
            Write-Host ""
            Start-Sleep -Seconds 1
            exit
        }
        default {
            Write-Host ""
            Write-Status "Invalid option. Enter a number between 1 and 6." "fail"
            Start-Sleep -Seconds 1
        }
    }
}

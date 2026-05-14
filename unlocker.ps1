# ===================================================================
#                  MINECRAFT BEDROCK UNLOCKER PRO
# ===================================================================

# Global Variables
$modsPath = Join-Path $env:APPDATA "Minecraft Bedrock\mods"
$backupPath = Join-Path $env:APPDATA "Minecraft Bedrock\.backup"
$gamePath = $null

$unlockUrl     = "https://raw.githubusercontent.com/shshamsff1/mc-unlocker-xenonrexo/main/mc/Unlock.dll"
$vcruntimeUrl  = "https://raw.githubusercontent.com/shshamsff1/mc-unlocker-xenonrexo/main/mc/vcruntime140_1.dll"
$modLoaderUrl  = "https://raw.githubusercontent.com/shshamsff1/mc-unlocker-xenonrexo/main/mc/ModLoader.dll"

# Function: Display Header
function Show-Header {
    Clear-Host
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        MINECRAFT BEDROCK UNLOCKER - PROFESSIONAL            ║" -ForegroundColor Cyan
    Write-Host "║════════════════════════════════════════════════════════════║" -ForegroundColor Cyan
    Write-Host "║  Made by Xenon Rexo | @xenonrexo                           ║" -ForegroundColor Aqua
    Write-Host "║  Version 2.0 - Enhanced Edition                            ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
}

# Function: Find Game Path
function Find-GamePath {
    Write-Host "[*] Searching for Minecraft game path..." -ForegroundColor Yellow
    
    $drives = Get-PSDrive -PSProvider FileSystem
    
    foreach ($drive in $drives) {
        $possiblePath = Join-Path $drive.Root "XboxGames\Minecraft for Windows\Content"
        
        if (Test-Path $possiblePath) {
            Write-Host "[✓] Found game at: $possiblePath" -ForegroundColor Green
            return $possiblePath
        }
    }
    
    return $null
}

# Function: Ask for Game Path
function Request-GamePath {
    Write-Host "`n[!] Minecraft game path not found automatically!" -ForegroundColor Yellow
    Write-Host "[?] Please enter your Xbox Games drive path (e.g., E:\XboxGames)" -ForegroundColor Cyan
    Write-Host ""
    
    $userPath = Read-Host "Enter path"
    
    if ([string]::IsNullOrWhiteSpace($userPath)) {
        Write-Host "[✗] Invalid path entered!" -ForegroundColor Red
        return $null
    }
    
    $contentPath = Join-Path $userPath "Minecraft for Windows\Content"
    
    if (Test-Path $contentPath) {
        Write-Host "[✓] Path verified successfully!" -ForegroundColor Green
        return $contentPath
    } else {
        Write-Host "[✗] Path does not exist! Please check and try again." -ForegroundColor Red
        return $null
    }
}

# Function: Create Backup
function Backup-GameFiles {
    Show-Header
    Write-Host "[*] Starting backup process..." -ForegroundColor Cyan
    
    if (!$gamePath) {
        $gamePath = Find-GamePath
        if (!$gamePath) {
            $gamePath = Request-GamePath
        }
        if (!$gamePath) {
            Write-Host "[✗] Cannot proceed without valid game path!" -ForegroundColor Red
            Pause
            return
        }
    }
    
    try {
        if (!(Test-Path $backupPath)) {
            New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
            Write-Host "[✓] Created backup folder" -ForegroundColor Green
        }
        
        Write-Host "[*] Backing up files..." -ForegroundColor Yellow
        
        $filesToBackup = @(
            "vcruntime140_1.dll",
            "ModLoader.dll"
        )
        
        foreach ($file in $filesToBackup) {
            $sourcePath = Join-Path $gamePath $file
            if (Test-Path $sourcePath) {
                Copy-Item -Path $sourcePath -Destination $backupPath -Force
                Write-Host "[✓] Backed up: $file" -ForegroundColor Green
            }
        }
        
        $modsBackupPath = Join-Path $backupPath "mods"
        if (Test-Path $modsPath) {
            if (Test-Path $modsBackupPath) {
                Remove-Item -Path $modsBackupPath -Recurse -Force
            }
            Copy-Item -Path $modsPath -Destination $modsBackupPath -Recurse -Force
            Write-Host "[✓] Backed up: mods folder" -ForegroundColor Green
        }
        
        Write-Host "`n[✓] Backup completed successfully!" -ForegroundColor Green
        Write-Host "[i] Backup location: $backupPath" -ForegroundColor Cyan
    }
    catch {
        Write-Host "[✗] Backup failed: $_" -ForegroundColor Red
    }
    
    Pause
}

# Function: Restore Game Files
function Restore-GameFiles {
    Show-Header
    Write-Host "[*] Starting restoration process..." -ForegroundColor Cyan
    
    if (!(Test-Path $backupPath)) {
        Write-Host "[✗] No backup found! Cannot restore." -ForegroundColor Red
        Pause
        return
    }
    
    if (!$gamePath) {
        $gamePath = Find-GamePath
        if (!$gamePath) {
            Write-Host "[✗] Cannot proceed without valid game path!" -ForegroundColor Red
            Pause
            return
        }
    }
    
    Write-Host "[!] This will restore your game to its state before unlocking." -ForegroundColor Yellow
    $confirm = Read-Host "[?] Are you sure? (yes/no)"
    
    if ($confirm -ne "yes") {
        Write-Host "[!] Restoration cancelled." -ForegroundColor Yellow
        Pause
        return
    }
    
    try {
        Write-Host "[*] Restoring files..." -ForegroundColor Yellow
        
        $filesToRestore = @(
            "vcruntime140_1.dll",
            "ModLoader.dll"
        )
        
        foreach ($file in $filesToRestore) {
            $backupFile = Join-Path $backupPath $file
            if (Test-Path $backupFile) {
                $destPath = Join-Path $gamePath $file
                Copy-Item -Path $backupFile -Destination $destPath -Force
                Write-Host "[✓] Restored: $file" -ForegroundColor Green
            }
        }
        
        $modsBackupPath = Join-Path $backupPath "mods"
        if (Test-Path $modsBackupPath) {
            if (Test-Path $modsPath) {
                Remove-Item -Path $modsPath -Recurse -Force
            }
            Copy-Item -Path $modsBackupPath -Destination $modsPath -Recurse -Force
            Write-Host "[✓] Restored: mods folder" -ForegroundColor Green
        }
        
        Write-Host "`n[✓] Game files restored successfully!" -ForegroundColor Green
        Write-Host "[i] Your game should be back to normal." -ForegroundColor Cyan
    }
    catch {
        Write-Host "[✗] Restoration failed: $_" -ForegroundColor Red
    }
    
    Pause
}

# Function: Look For Game Path
function Search-GamePath {
    Show-Header
    Write-Host "[*] Searching for game installation..." -ForegroundColor Cyan
    
    $foundPath = Find-GamePath
    
    if ($foundPath) {
        Write-Host "[✓] Game found successfully!" -ForegroundColor Green
        Write-Host "[i] Path: $foundPath" -ForegroundColor Cyan
        $script:gamePath = $foundPath
    } else {
        Write-Host "[!] Game not found. Attempting manual configuration..." -ForegroundColor Yellow
        $manualPath = Request-GamePath
        if ($manualPath) {
            Write-Host "[✓] Game path set successfully!" -ForegroundColor Green
            $script:gamePath = $manualPath
        } else {
            Write-Host "[✗] Failed to locate or configure game path." -ForegroundColor Red
        }
    }
    
    Pause
}

# Function: Unlock Game
function Unlock-Game {
    Show-Header
    Write-Host "[*] Preparing to unlock Minecraft Bedrock..." -ForegroundColor Cyan
    
    # Find or request game path
    if (!$gamePath) {
        $gamePath = Find-GamePath
        if (!$gamePath) {
            Write-Host "`n[!] Game path not found automatically." -ForegroundColor Yellow
            $gamePath = Request-GamePath
            if (!$gamePath) {
                Write-Host "[✗] Cannot proceed without valid game path!" -ForegroundColor Red
                Pause
                return
            }
        }
    }
    
    try {
        # Create mods folder
        if (!(Test-Path $modsPath)) {
            New-Item -ItemType Directory -Path $modsPath -Force | Out-Null
            Write-Host "[✓] Created mods folder" -ForegroundColor Green
        }
        
        Write-Host "`n[*] Downloading required files..." -ForegroundColor Yellow
        
        # Download Unlock.dll
        Write-Host "[↓] Downloading Unlock.dll..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $unlockUrl -OutFile (Join-Path $modsPath "unlock.dll") -ErrorAction Stop
        Write-Host "[✓] Unlock.dll downloaded" -ForegroundColor Green
        
        # Download vcruntime
        Write-Host "[↓] Downloading vcruntime140_1.dll..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $vcruntimeUrl -OutFile (Join-Path $gamePath "vcruntime140_1.dll") -ErrorAction Stop
        Write-Host "[✓] vcruntime140_1.dll downloaded" -ForegroundColor Green
        
        # Download ModLoader
        Write-Host "[↓] Downloading ModLoader.dll..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $modLoaderUrl -OutFile (Join-Path $gamePath "ModLoader.dll") -ErrorAction Stop
        Write-Host "[✓] ModLoader.dll downloaded" -ForegroundColor Green
        
        # Success message
        Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║             ✓ UNLOCK SUCCESSFUL!                          ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host "[✓] All files successfully installed!" -ForegroundColor Green
        Write-Host "[✓] Game is ready to run!" -ForegroundColor Green
        Write-Host "[!] OPEN MINECRAFT AND ENJOY! :)" -ForegroundColor Yellow
        Write-Host "[i] Game path: $gamePath" -ForegroundColor Cyan
    }
    catch {
        Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║             ✗ UNLOCK FAILED!                             ║" -ForegroundColor Red
        Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host "[✗] Error: $_" -ForegroundColor Red
    }
    
    Pause
}

# Function: Show Menu
function Show-Menu {
    Show-Header
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                     MAIN MENU                              ║" -ForegroundColor Cyan
    Write-Host "╠════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║                                                            ║" -ForegroundColor Cyan
    Write-Host "║  1. Unlock Game              - Unlock Minecraft Bedrock   ║" -ForegroundColor Green
    Write-Host "║  2. Backup Files             - Create backup of files    ║" -ForegroundColor Yellow
    Write-Host "║  3. Restore Game Files       - Restore from backup       ║" -ForegroundColor Cyan
    Write-Host "║  4. Look For Game Path       - Search for game location  ║" -ForegroundColor Magenta
    Write-Host "║  5. Exit                     - Close this application    ║" -ForegroundColor Red
    Write-Host "║                                                            ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

# Main Loop
while ($true) {
    Show-Menu
    $choice = Read-Host "`n[?] Enter your choice (1-5)"
    
    switch ($choice) {
        "1" { Unlock-Game }
        "2" { Backup-GameFiles }
        "3" { Restore-GameFiles }
        "4" { Search-GamePath }
        "5" { 
            Write-Host "`n[!] Thank you for using Minecraft Bedrock Unlocker!" -ForegroundColor Aqua
            Write-Host "[i] Made by Xenon Rexo | @xenonrexo" -ForegroundColor Cyan
            exit 
        }
        default {
            Write-Host "[✗] Invalid choice! Please enter 1-5." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}

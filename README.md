# MC Unlocker - By Xenon Rexo

A simple PowerShell launcher for Minecraft Bedrock mod unlocking and backup management.

## What it does

This script provides a clean interactive menu to:

- Install **Minecraft for Windows (Xbox)** via the Xbox Store page
- Unlock Minecraft Bedrock by downloading mod files
- Backup game files before unlocking
- Restore game files from backup
- Detect or set the Minecraft game path

## How to run

Open PowerShell and run:

```powershell
irm "http://raw.githubusercontent.com/shshamsff1/mc-unlocker-xenonrexo/main/unlocker.ps1" | iex
```

> `irm` is short for `Invoke-RestMethod`, and `iex` runs the downloaded script immediately.

## Menu options

After the script opens, choose one of the menu items:

1. **Install Minecraft For Windows (Xbox)**
   - Opens the Xbox store page for Minecraft: Bedrock Edition.
2. **Unlock Game**
   - Installs the unlock files needed for Bedrock modding.
3. **Backup Game Files**
   - Saves current game files to `%APPDATA%\Minecraft Bedrock\.backup`.
4. **Restore Game Files From Backup**
   - Restores files from backup to undo the unlock.
5. **Look For Game Path**
   - Searches your drives for the Minecraft content folder, or lets you enter it manually.
6. **Exit**
   - Closes the script.

## Notes

- The script is made for Minecraft Bedrock installed through Xbox / Game Pass.
- If it cannot detect your game folder automatically, it will ask you for the XboxGames path.
- Backups are stored at:

```powershell
$env:APPDATA\Minecraft Bedrock\.backup
```

## License

Use at your own risk. This script is provided as-is and is intended for educational and personal use only.

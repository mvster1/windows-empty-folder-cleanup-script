# Safe Empty Directory Cleanup

A PowerShell script that safely identifies and removes empty directories from common Windows system locations. This tool helps maintain a clean system by removing leftover empty folders from uninstalled programs and temporary operations.

## 🛡️ Safety Features

- **Only removes completely empty directories** - no files or subdirectories present
- **Non-recursive scanning** - only checks direct child folders, not nested structures
- **Double verification** - confirms directory is still empty before deletion
- **Permission handling** - gracefully handles access denied scenarios
- **Preview mode** - see what would be deleted without making changes
- **Interactive confirmation** - prompts before deletion unless forced

## 📂 Scanned Locations

The script scans the following system locations for empty directories:

### Program Files
- `Program Files`
- `Program Files (x86)`

### User Data (AppData)
- `%LOCALAPPDATA%` (AppData\Local)
- `%APPDATA%` (AppData\Roaming)
- `%LOCALAPPDATA%\..\LocalLow` (AppData\LocalLow)

### System Temporary Folders
- `%TEMP%` (User temporary folder)
- `%TMP%` (Alternative temp folder)
- `%WINDIR%\Temp` (System temporary folder)
- `%PROGRAMDATA%` (Shared application data)

### User Folders
- `%USERPROFILE%\Downloads`
- `%USERPROFILE%\Desktop`
- `%USERPROFILE%\Documents`
- `%PUBLIC%` (Public user folder)

### Cache & Temporary Data
- `%LOCALAPPDATA%\Microsoft\Windows\INetCache` (IE/Edge cache)
- `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache`
- `%LOCALAPPDATA%\Mozilla\Firefox\Profiles`
- `%LOCALAPPDATA%\Packages` (Microsoft Store apps)

### Additional System Locations
- `C:\Users\Public`
- `%ALLUSERSPROFILE%`

## 🚀 Usage

### Prerequisites
- Windows PowerShell 5.1 or PowerShell Core 7+
- Administrator privileges recommended (for system folders)

### Basic Usage

```powershell
# Preview mode - see what would be deleted (RECOMMENDED FIRST RUN)
.\script.ps1 -WhatIf

# Interactive mode with confirmation prompt
.\script.ps1

# Skip confirmation prompt
.\script.ps1 -Force
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-WhatIf` | Switch | Preview mode - shows what would be deleted without making changes |
| `-Force` | Switch | Skip the confirmation prompt and proceed with deletion |

## 📋 Use Cases

### System Maintenance
- Clean up after uninstalling programs that leave empty folders
- Remove temporary directories that weren't automatically cleaned
- Maintain organized system folders

### Development Environment Cleanup
- Clean empty folders after project deletions
- Remove leftover build/cache directories
- Maintain clean development workspace

### Storage Optimization
- Remove clutter from system drives
- Prepare system for disk imaging
- Clean up before system backups

### Post-Migration Cleanup
- Clean up after moving user profiles
- Remove empty folders after data migration
- System cleanup after OS upgrades

## 🔍 Example Output

```
Scanning for empty directories in:
  C:\Program Files
  C:\Program Files (x86)
  C:\Users\Username\AppData\Local
  C:\Users\Username\AppData\Roaming
  C:\Users\Username\AppData\LocalLow
  ...

Scanning C:\Program Files...
Scanning C:\Program Files (x86)...
...

Found 5 empty directories:
  In C:\Program Files:
    OldSoftware
    TempInstall
  In C:\Users\Username\AppData\Local:
    EmptyCache
    UnusedApp
  In C:\Users\Username\Downloads:
    OldDownloads

Do you want to delete these 5 empty directories? (y/N): y

Removing empty directories...
  Removed: C:\Program Files\OldSoftware
  Removed: C:\Program Files\TempInstall
  Permission denied: C:\Users\Username\AppData\Local\EmptyCache
  Removed: C:\Users\Username\AppData\Local\UnusedApp
  Removed: C:\Users\Username\Downloads\OldDownloads

Operation completed:
  Successfully removed: 4 directories
  Errors encountered: 1 directories
```

## ⚠️ Important Notes

### What Gets Deleted
- **ONLY** directories that are completely empty (no files, no subdirectories)
- Only direct child directories of scanned locations (not recursive)
- Directories are verified empty twice before deletion

### What Does NOT Get Deleted
- Directories with any files (including hidden files)
- Directories with subdirectories (even empty ones)
- Directories the script cannot access due to permissions
- System-critical directories (script only scans safe locations)

### Recommendations
1. **Always run with `-WhatIf` first** to preview changes
2. **Run as Administrator** for complete system access
3. **Close all applications** before running to avoid permission issues
4. **Review the list** of directories before confirming deletion

## 🛠️ Technical Details

- **Language**: PowerShell
- **Requires**: PowerShell 5.1+
- **Platform**: Windows
- **Cmdlet Support**: Uses `[CmdletBinding(SupportsShouldProcess)]` for proper PowerShell integration

## 📄 License

This script is provided as-is for educational and system maintenance purposes. Use at your own discretion and always test in a safe environment first.

## 🤝 Contributing

Feel free to submit issues, feature requests, or improvements to make this tool even safer and more useful for the community.

---

**⚡ Quick Start**: Run `.\script.ps1 -WhatIf` to safely preview what would be cleaned!

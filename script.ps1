# Safe Empty Directory Cleanup - Comprehensive System Cleanup
# This script finds and removes empty directories from multiple system locations
# (only checks direct children, not subdirectories recursively)
# IMPORTANT: Only completely empty directories are removed for safety
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Force
)

# Define paths to scan
$ScanPaths = @(
    # Program Files
    $Env:ProgramFiles,
    ${Env:ProgramFiles(x86)},
    
    # AppData folders
    "$Env:LOCALAPPDATA",
    "$Env:APPDATA",
    "$Env:LOCALAPPDATA\..\LocalLow",
    
    # System temporary folders
    $Env:TEMP,
    $Env:TMP,
    "$Env:WINDIR\Temp",
    $Env:ProgramData,
    
    # User folders
    "$Env:USERPROFILE\Downloads",
    "$Env:USERPROFILE\Desktop",
    "$Env:USERPROFILE\Documents",
    $Env:PUBLIC,
    
    # Cache and temporary data folders
    "$Env:LOCALAPPDATA\Microsoft\Windows\INetCache",
    "$Env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$Env:LOCALAPPDATA\Mozilla\Firefox\Profiles",
    "$Env:LOCALAPPDATA\Packages",
    
    # Additional locations
    "C:\Users\Public",
    $Env:ALLUSERSPROFILE
)

# Remove null/empty paths and verify they exist
$ScanPaths = $ScanPaths | Where-Object { $_ -and (Test-Path $_) }

Write-Host "Scanning for empty directories in:" -ForegroundColor Green
$ScanPaths | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
Write-Host ""

# Find empty directories directly in scan folders (not recursive)
$EmptyDirs = @()
foreach ($Path in $ScanPaths) {
    Write-Host "Scanning $Path..." -ForegroundColor Yellow
   
    try {
        # Get only direct child directories (no -Recurse)
        $Directories = Get-ChildItem -Path $Path -Directory -Force -ErrorAction Stop
       
        foreach ($Dir in $Directories) {
            try {
                # Check if directory is completely empty (no files or subdirectories)
                $Contents = Get-ChildItem -Path $Dir.FullName -Force -ErrorAction Stop
               
                if ($Contents.Count -eq 0) {
                    $EmptyDirs += $Dir
                }
            }
            catch {
                Write-Warning "Cannot access directory: $($Dir.FullName) - $($_.Exception.Message)"
            }
        }
    }
    catch {
        Write-Error "Cannot scan path $Path - $($_.Exception.Message)"
        continue
    }
}

if ($EmptyDirs.Count -eq 0) {
    Write-Host "No empty directories found." -ForegroundColor Green
    exit 0
}

# Display found empty directories grouped by location
Write-Host "Found $($EmptyDirs.Count) empty directories:" -ForegroundColor Cyan

# Group by parent directory for better organization
$GroupedDirs = $EmptyDirs | Group-Object { Split-Path $_.FullName -Parent }
foreach ($Group in $GroupedDirs) {
    Write-Host "  In $($Group.Name):" -ForegroundColor Yellow
    $Group.Group | ForEach-Object {
        Write-Host "    $($_.Name)" -ForegroundColor Gray
    }
}
Write-Host ""

# Handle WhatIf parameter (built-in from SupportsShouldProcess)
if ($WhatIfPreference) {
    Write-Host "WhatIf: Would remove $($EmptyDirs.Count) empty directories" -ForegroundColor Magenta
    exit 0
}

# Confirmation prompt (unless -Force is used)
if (-not $Force) {
    $Response = Read-Host "Do you want to delete these $($EmptyDirs.Count) empty directories? (y/N)"
    if ($Response -notmatch '^[Yy]') {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Remove empty directories
$SuccessCount = 0
$ErrorCount = 0
Write-Host "Removing empty directories..." -ForegroundColor Yellow

foreach ($Dir in $EmptyDirs) {
    try {
        # Double-check the directory is still empty before deletion
        $Contents = Get-ChildItem -Path $Dir.FullName -Force -ErrorAction Stop
       
        if ($Contents.Count -eq 0) {
            Remove-Item -Path $Dir.FullName -Force -ErrorAction Stop
            Write-Host "  Removed: $($Dir.FullName)" -ForegroundColor Green
            $SuccessCount++
        }
        else {
            Write-Warning "Skipped (no longer empty): $($Dir.FullName)"
        }
    }
    catch {
        if ($_.Exception -is [System.UnauthorizedAccessException] -or $_.Exception.Message -match "Access.*denied") {
            Write-Host "  Permission denied: $($Dir.FullName)" -ForegroundColor Red
        } else {
            Write-Host "  Failed to remove: $($Dir.FullName) - $($_.Exception.Message)" -ForegroundColor Red
        }
        $ErrorCount++
    }
}

# Summary
Write-Host ""
Write-Host "Operation completed:" -ForegroundColor Cyan
Write-Host "  Successfully removed: $SuccessCount directories" -ForegroundColor Green
if ($ErrorCount -gt 0) {
    Write-Host "  Errors encountered: $ErrorCount directories" -ForegroundColor Red
}

# Usage Examples:
# .\cleanup-empty-dirs.ps1 -WhatIf          # Preview what would be deleted
# .\cleanup-empty-dirs.ps1                  # Interactive mode with confirmation
# .\cleanup-empty-dirs.ps1 -Force          # Skip confirmation prompt
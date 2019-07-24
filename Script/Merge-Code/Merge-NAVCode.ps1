function Merge-NewCumulativeUpdate($WorkingFolder, $Version, $TargetDatabase, $ResultDatabase) 
{
    # Test if working folder exists!
    if (-not (Test-Path -Path $WorkingFolder))
    {
        Write-Error "Working folder $WorklingFolder does not exist."
        break script
    }

    # Get urls for last two dvds
        #TODO: Use Web Library Get-VersionMap to get URL for downloading...
        $W1DVDOrg = "https://download.microsoft.com/download/3/5/3/353B5669-042D-4EE2-B76A-13D9A1A0621D/CU 01 NAV 2018 W1.zip"
        $W1DVDMod = "https://download.microsoft.com/download/C/3/C/C3C91857-0DB6-4619-A386-BF9D779F705E/CU 02 NAV 2018 W1.zip"    

    # Copy last two dvds from web.
        . ".\Library\WEB\Copy-WebItem.ps1"
        Copy-WebItem -ItemURL $W1DVDOrg "$WorkingFolder\DVD\ORG.zip"
        Copy-WebItem -ItemURL $W1DVDMod "$WorkingFolder\DVD\MOD.zip"

    # Extract zip files
        . ".\Library\CMD\Use-ZIPFile.ps1"
        Restore-NAVDVD -WorkingFolder $WorkingFolder -SubFolder "DVD\ORG"
        Restore-NAVDVD -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD"

    # Restore sql bak files
        . ".\Library\NAV\Use-NAVDVD.ps1"
        . ".\Library\SQL\Import-SQLModule.ps1"
        Import-SQLModule
        . ".\Library\SQL\Restore-Database.ps1"
        Restore-Database -BackupFile (Get-NAVDBBackupFile -WorkingFolder $WorkingFolder -SubFolder "DVD\ORG" -Version $Version) -Database "TMP_NAV_$($Version)_ORG"
        Restore-Database -BackupFile (Get-NAVDBBackupFile -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD" -Version $Version) -Database "TMP_NAV_$($Version)_MOD"

    # Export NAV objects to txt files
        . ".\Library\NAV\Export-NAVObject.ps1"
        Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder $WorkingFolder -SubFolder "DVD\ORG" -Version $Version)
        Export-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_ORG" -ExportFile $("$WorkingFolder\CODE\ORG-All.txt") -OutputFolder $("$WorkingFolder\CODE") -filter ""
        
        # Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder $WorkingFolder -SubFolder "DVD\ORG" -Version $Version) # This line is not needed if it follows ORG export. They need to be the same version.
        Export-NAVObject -VersionNo $Version -DatabaseName $TargetDatabase -ExportFile $("$WorkingFolder\CODE\TAR-All.txt") -OutputFolder $("$WorkingFolder\CODE") -filter "ID=1..130000|150000.."
        Export-NAVObject -VersionNo $Version -DatabaseName $TargetDatabase -ExportFile $("$WorkingFolder\TTS\TAR-All.txt") -OutputFolder $("$WorkingFolder\TTS") -filter "ID=130000..150000"
        
        Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD" -Version $Version)
        Export-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_MOD" -ExportFile $("$WorkingFolder\CODE\MOD-All.txt") -OutputFolder $("$WorkingFolder\CODE") -filter ""
       
    
    # Split files into CODE folder
        . ".\Library\NAV\Split-NAVObject.ps1"
        New-Item -Path $WorkingFolder -Name "CODE" -ItemType Directory -Force | Out-Null
        Split-NAVObject -SourceFile $("$WorkingFolder\CODE\ORG-All.txt") -WorkingFolder $("$WorkingFolder\CODE") -SubFolder "ORG"
        Split-NAVObject -SourceFile $("$WorkingFolder\CODE\MOD-All.txt") -WorkingFolder $("$WorkingFolder\CODE") -SubFolder "MOD"
        Split-NAVObject -SourceFile $("$WorkingFolder\CODE\TAR-All.txt") -WorkingFolder $("$WorkingFolder\CODE") -SubFolder "TAR"
        
        New-Item -Path $WorkingFolder -Name "TTS" -ItemType Directory -Force | Out-Null
        Split-NAVObject -SourceFile $("$WorkingFolder\TTS\TAR-All.txt") -WorkingFolder $("$WorkingFolder\TTS") -SubFolder "TAR"

    # Merge files
        . ".\Library\NAV\Merge-NAVObject.ps1"
        Merge-NAVObject -WorkingFolder $("$WorkingFolder\CODE") -OriginalPath "ORG" -ModifiedPath "MOD" -TargetPath "TAR" -ResultPath "RES"

    # Test if conflicts are merged
    if ((Get-ChildItem -Path "C:\temp\CODE\RES\" -Filter *.conflict).COUNT -gt 0)
    {
        Write-Host "Merge has been stoped with conflicts. Resolve conflics and set files with extension .conflict into .conflict.ok. and repeat this task."
        return
    }

    # Backup target database and create new databse
        .".\Library\SQL\Backup-Database.ps1"
        Backup-Database -Database $TargetDatabase -BackupFile (Join-Path $WorkingFolder "DVD\TAR.bak")
        Restore-Database -BackupFile (Join-Path $WorkingFolder "DVD\TAR.bak") -Database $ResultDatabase

    # Convert database to new version if needed.
        .".\Library\NAV\Invoke-NAVConversion.ps1"
        Invoke-NAVConversion -DatabaseName $ResultDatabase -LogPath "$WorkingFolder\CODE"
    
    # Import merged files into database
        . ".\Library\NAV\Join-NAVObject.ps1"
        Join-NAVObject -WorkingFolder "$WorkingFolder\CODE" -SubFolder "RES" -ResultFile "RES-All.txt"
        . ".\Library\NAV\Import-NAVObject.ps1"
        Import-NAVObject -DatabaseName $ResultDatabase -ImportFile "$WorkingFolder\CODE\RES-All.txt" -OutputFolder $("$WorkingFolder\CODE")

    # Synchronize by calling service (works only locally)    
        . ".\Library\NAV\Sync-NAVObject.ps1"
        Sync-NAVObject -Version "110"        

    # Recompile final database
        . ".\Library\NAV\Compile-NAVObject.ps1"
        Invoke-NAVObjectCompilation -DatabaseName $ResultDatabase

    # End of script
        . ".\Library\CMD\Invoke-Alarm.ps1"
        Invoke-Alarm
    Write-Host "Finished."
}

function Remove-WorkingItem($RemoveDatabase=$true)
{
    if ($RemoveDatabase)
    {
        # Droping temporary databases
        . ".\Library\SQL\Remove-Database.ps1"
        Remove-Database -Database "TMP_NAV_$($Version)_ORG"
        Remove-Database -Database "TMP_NAV_$($Version)_MOD"
    }
}

# Example:
# Merge-NewCumulativeUpdate -WorkingFolder "C:\temp" -Version "110" -TargetDatabase "LOCAL_NAV_110_DEV" -ResultDatabase "NEW_NAV_110_DEV"
# Remove-WorkingItem -RemoveDatabase $true 

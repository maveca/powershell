function Merge-TTSNewCumulativeUpdate($WorkingFolder, $Version, $TargetDatabase, $ResultDatabase) 
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

    # Import TTS objects and export them into txt.
        . ".\Library\NAV\Import-NAVObject.ps1"
        . ".\Library\NAV\Export-NAVObject.ps1"
        # Original
            Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder $WorkingFolder -SubFolder "DVD\ORG" -Version $Version)
            Import-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_ORG" -ImportFile "$WorkingFolder\DVD\ORG\NAVDVD\TestToolKit\CALTestRunner.fob" -OutputFolder "$WorkingFolder\TTS\ORG"
            Import-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_ORG" -ImportFile "$WorkingFolder\DVD\ORG\NAVDVD\TestToolKit\CALTestLibraries.W1.fob" -OutputFolder "$WorkingFolder\TTS\ORG"
            Import-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_ORG" -ImportFile "$WorkingFolder\DVD\ORG\NAVDVD\TestToolKit\CALTestCodeunits.W1.fob" -OutputFolder "$WorkingFolder\TTS\ORG"
            Export-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_ORG" -ExportFile $("$WorkingFolder\TTS\ORG-All.txt") -OutputFolder $("$WorkingFolder\TTS") -filter "ID=130000..150000"
        # Target
            Export-NAVObject -VersionNo $Version -DatabaseName $TargetDatabase -ExportFile $("$WorkingFolder\TTS\TAR-All.txt") -OutputFolder $("$WorkingFolder\TTS") -filter "ID=130000..150000"
        # Modified
            Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD" -Version $Version)
            Import-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_MOD" -ImportFile "$WorkingFolder\DVD\MOD\NAVDVD\TestToolKit\CALTestRunner.fob" -OutputFolder "$WorkingFolder\TTS\MOD"
            Import-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_MOD" -ImportFile "$WorkingFolder\DVD\MOD\NAVDVD\TestToolKit\CALTestLibraries.W1.fob" -OutputFolder "$WorkingFolder\TTS\MOD"
            Import-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_MOD" -ImportFile "$WorkingFolder\DVD\MOD\NAVDVD\TestToolKit\CALTestCodeunits.W1.fob" -OutputFolder "$WorkingFolder\TTS\MOD"
            Export-NAVObject -VersionNo $Version -DatabaseName "TMP_NAV_$($Version)_MOD" -ExportFile $("$WorkingFolder\TTS\MOD-All.txt") -OutputFolder $("$WorkingFolder\TTS") -filter "ID=130000..150000"       
   
    # Split files into TTS folder
        . ".\Library\NAV\Split-NAVObject.ps1"
        New-Item -Path $WorkingFolder -Name "TTS" -ItemType Directory -Force | Out-Null
        Split-NAVObject -SourceFile $("$WorkingFolder\TTS\ORG-All.txt") -WorkingFolder $("$WorkingFolder\TTS") -SubFolder "ORG"
        Split-NAVObject -SourceFile $("$WorkingFolder\TTS\MOD-All.txt") -WorkingFolder $("$WorkingFolder\TTS") -SubFolder "MOD"
        Split-NAVObject -SourceFile $("$WorkingFolder\TTS\TAR-All.txt") -WorkingFolder $("$WorkingFolder\TTS") -SubFolder "TAR"

    # Merge files
        . ".\Library\NAV\Merge-NAVObject.ps1"
        Merge-NAVObject -WorkingFolder $("$WorkingFolder\TTS") -OriginalPath "ORG" -ModifiedPath "TAR" -TargetPath "MOD" -ResultPath "RES"
        # NOTE: Values of parameters -ModifiedPath and -TargetPath are exchanged due to smaller conflicts.

    # Update object properties        
        . ".\Library\NAV\Merge-NAVProperty.ps1"
        Merge-NAVProperty -WorkingPath "C:\Temp\TTS" -ModifiedPath "MOD" -TargetPath "TAR" -ResultPath "RES"

    # Test if conflicts are merged
    if ((Get-ChildItem -Path "C:\temp\TTS\RES\" -Filter *.conflict).COUNT -gt 0)
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
        Invoke-NAVConversion -DatabaseName $ResultDatabase -LogPath "$WorkingFolder\TTS"
    
    # Import merged files into database
        . ".\Library\NAV\Join-NAVObject.ps1"
        Join-NAVObject -WorkingFolder "$WorkingFolder\TTS" -SubFolder "RES" -ResultFile "RES-All.txt"
        . ".\Library\NAV\Import-NAVObject.ps1"
        Import-NAVObject -DatabaseName $ResultDatabase -ImportFile "$WorkingFolder\TTS\RES-All.txt" -OutputFolder $("$WorkingFolder\TTS")

    # Synchronize by calling service (works only locally)    
        . ".\Library\NAV\Sync-NAVObject.ps1"
        Import-NavAdminTool (Get-NAVSVCFolder -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD" -Version $Version)
        Sync-NAVObject -Version "110"        

    # Recompile final database
        . ".\Library\NAV\Compile-NAVObject.ps1"
        Invoke-NAVObjectCompilation -DatabaseName $ResultDatabase

    # End of script
        . ".\Library\CMD\Invoke-Alarm.ps1"
        Invoke-Alarm
    Write-Host "Finished."
}

# Example:
# Merge-TTSNewCumulativeUpdate -WorkingFolder "C:\temp" -Version "110" -TargetDatabase "LOCAL_NAV_110_DEV" -ResultDatabase "NEW_NAV_110_DEV"
$WorkingFolder = "C:\temp" 
$Version = "110" 
$TargetDatabase = "LOCAL_NAV_110_DEV" 
$ResultDatabase = "NEW_NAV_110_DEV"
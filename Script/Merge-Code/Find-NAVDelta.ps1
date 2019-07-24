function Find-NAVDelta($WorkingFolder, $Version, $DevServerName, $DevDatabaseName, $ResServerName = "(local)", $ResDatabaseName)
{
    # Scenario: While creating new build, developers will interact with existing DEV database. 
    # When new database is prepared, export DEV database, find changes and apply to latest build. 

    . ".\Library\NAV\Use-NAVDVD.ps1"
    Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder $WorkingFolder -SubFolder "DVD\ORG" -Version $Version)

    . ".\Library\NAV\Export-NAVObject.ps1"
    Export-NAVObject -ServerName $DevServerName -DatabaseName $DevDatabaseName -ExportFile "$WorkingFolder\CODE\DEV-All.txt" -OutputFolder "$WorkingFolder\CODE" -filter "ID=1..130000|150000.."

    . ".\Library\NAV\Split-NAVObject.ps1"
    Split-NAVObject -SourceFile $("$WorkingFolder\CODE\DEV-All.txt") -WorkingFolder $("$WorkingFolder\CODE") -SubFolder "DEV"

    . ".\Library\NAV\Compare-NAVObject.ps1"
    Compare-NAVObject -WorkingFolder $WorkingFolder -OriginalFolder "TAR" -ModifiedFolder "DEV" 

    # Test if conflicts are merged
    if ((Get-ChildItem -Path "C:\Temp\CODE\DEV\DEL\" -Filter *.conflict).COUNT -gt 0)
    {
        Write-Host "Merge has been stoped with conflicts. Resolve conflics and set files with extension .conflict into .conflict.ok. and repeat this task."
        return
    }    

    # . ".\Library\NAV\Join-NAVObject.ps1"
    # Join-NAVObject -WorkingFolder "C:\temp\CODE\DEV" -SubFolder "NEW" -ResultFile "NEW-All.txt"
    
    # . ".\Library\NAV\Import-NAVObject.ps1"
    # Import-NAVObject -DatabaseServer $ResServerName -DatabaseName $ResDatabaseName -ImportFile "$WorkingFolder\CODE\DEV\NEW-All.txt" -OutputFolder $("$WorkingFolder\CODE")

    # . ".\Library\NAV\Use-NAVDVD.ps1"
    # Import-NavAdminTool (Get-NAVSVCFolder -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD" -Version $Version)
    # Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD" -Version $Version)

    # . ".\Library\NAV\Sync-NAVObject.ps1"
    # Sync-NAVObject -Version "110"

    # . ".\Library\NAV\Compile-NAVObject.ps1"
    # Invoke-NAVObjectCompilation -DatabaseName $ResDatabaseName    
}

# Example:
# Find-NAVDelta -WorkingFolder "C:\temp" -Version "110" -DevServerName "NAVDEV-LJ-19" -DevDatabaseName "ADACTA_NAV_110_DEV" -ResDatabaseName "NEW_NAV_110_DEV"
$WorkingFolder = "C:\temp" 
$Version = "110" 
$ResDatabaseName = "NEW_NAV_110_DEV"
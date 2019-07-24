# Scenario: Microsoft releases new Cumulative Update. Code must be merged with current DEV database.
. ".\Script\Merge-Code\Merge-NAVCode.ps1"
Merge-NewCumulativeUpdate -WorkingFolder "C:\temp" -Version "110" -TargetDatabase "LOCAL_NAV_110_DEV" -TargetBackupFile "C:\temp\Target.bak" -ResultDatabase "NEW_NAV_110_DEV"

# Scenario: Microsoft releases new Cumulative Update. Test tool set must be merged with current DEV database separately from Code. There are some difference when merging code.
. ".\Script\Merge-Code\Merge-TTSCode.ps1"
Merge-TTSCumulativeUpdate -WorkingFolder "C:\temp" -Version "110" -TargetDatabase "LOCAL_NAV_110_DEV" -TargetBackupFile "C:\temp\Target.bak" -ResultDatabase "NEW_NAV_110_DEV"

# Scenario: When merging is too long process some developers can already push new code to the DEV environment. Test and isolate diferences in DEV folder.
. ".\Script\Merge-Code\Find-NAVDelta.ps1"
Find-NAVDelta -WorkingFolder "C:\temp" -Version "110" -DevServerName "NAVDEV-LJ-19" -DevDatabaseName "ADACTA_NAV_110_DEV" -ResDatabaseName "NEW_NAV_110_DEV"

# Export all into fob
. ".\Library\NAV\Use-NAVDVD.ps1"
Import-NavModelTool -BUILDbinaries "C:\Program Files (x86)\Microsoft Dynamics NAV\110.20348\RoleTailored Client"
. ".\Library\NAV\Export-NAVObject.ps1"
Export-NAVObject -VersionNo "110" -DatabaseName "NEW_NAV_110_DEV" -ExportFile "C:\temp\all.fob" -OutputFolder "C:\temp"

# Import all from fob
. ".\Library\NAV\Use-NAVDVD.ps1"
Import-NavModelTool -BUILDbinaries "C:\Program Files (x86)\Microsoft Dynamics NAV\110.20348\RoleTailored Client"
. ".\Library\NAV\Import-NAVObject.ps1"
Import-NAVObject -VersionNo "110" -DatabaseName "NEW_NAV_110_DEV" -ImportFile "C:\temp\all.fob" -OutputFolder "C:\temp"
. ".\Library\NAV\Sync-NAVObject.ps1"
Sync-NAVObject -Version "110"

git clone 'https://github.com/maveca/hrdemo.git'


Remove-Item -path "hrdemo" -force -recurse
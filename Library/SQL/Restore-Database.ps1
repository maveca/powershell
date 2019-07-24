. ".\Library\SQL\Test-Database.ps1"

function Restore-Database($BackupFile, $ServerName = "(local)", $Database)
{
    if (-not (Test-Database -Databse $Database -Server $ServerName))
    {
        try {
            Write-Host "Restoring database $Database on server $ServerName" -NoNewline
            $dbServer = New-Object Microsoft.SqlServer.Management.Smo.Server($ServerName)
            $dbRestore = New-object Microsoft.SqlServer.Management.Smo.Restore
            $dbRestore.Database = $Database
            $dbRestore.NoRecovery = $false
            $dbRestore.ReplaceDatabase = $true
            $dbRestore.Action = [Microsoft.SqlServer.Management.Smo.RestoreActionType]::Database
            $backupDevice = New-Object Microsoft.SqlServer.Management.Smo.BackupDeviceItem($BackupFile, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
            $dbRestore.Devices.Add($backupDevice)
            $dbFileList = $dbRestore.ReadFileList($dbServer)
        
            $dbRestoreFile = New-object Microsoft.SqlServer.Management.Smo.RelocateFile
            $dbRestoreLog = New-object Microsoft.SqlServer.Management.Smo.RelocateFile
            $dbRestoreFile.LogicalFileName = $dbFileList.Select("Type = 'D'")[0].LogicalName
            $dbRestoreLog.LogicalFileName = $dbFileList.Select("Type = 'L'")[0].LogicalName
            $dbRestoreFile.PhysicalFileName = $dbServer.Settings.DefaultFile + $Database  + "_Data.mdf"
            $dbRestoreLog.PhysicalFileName = $dbServer.Settings.DefaultFile + $Database  + "_Log.ldf"
            $dbRestore.RelocateFiles.Add($dbRestoreFile) | Out-Null
            $dbRestore.RelocateFiles.Add($dbRestoreLog) | Out-Null
        
            $dbServer.KillAllProcesses($dbRestore.Database)
            $dbRestore.SqlRestore($dbServer)
            Write-Host " has been completed."
        }
        catch {
            Write-Warning $error[0]
        }
    } else {
        Write-Warning "Database $Database already exists."
    }
}

# Example:
# . ".\Library\SQL\Import-SQLModule.ps1"
# Import-SQLModule
# Restore-Database -BackupFile "C:\Aleksander\Temp\ORG\NAVDVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\110\Database\Demo Database NAV (11-0).bak" -Database "demodb" 

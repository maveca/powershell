function Backup-Database($ServerName = "(local)", $Database, $BackupFile)
{
    if (-not (Test-Path $BackupFile)){
        Write-Host "Backing up database $Database to $BackupFile" -NoNewline
        $dbServer = New-Object Microsoft.SqlServer.Management.Smo.Server($ServerName)
        $dbServer.ConnectionContext.StatementTimeout = 0
        $dbBackup = New-Object Microsoft.SqlServer.Management.Smo.Backup
        $dbBackup.Database = $Database 
        $dbBackup.Devices.AddDevice($BackupFile, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
        $dbBackup.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database
        $dbBackup.SqlBackup($dbServer)
        Write-Host " has been completed."
    } else {
        Write-Warning "Backup file $BackupFile already exists."
        return
    }
}
function Sync-NAVObject ($Version){
    $Version = $Version.SubString(0, $Version.length-1)
    # Stop NAV services
    $ServerInstances = Get-NAVServerInstance | Where-Object { ($_.Version -like "$Version.*") -and ($_.DisplayName -like 'Microsoft Dynamics NAV Server*') }
    foreach ($ServerInstance in $ServerInstances)
    {
        Write-Host "Syncing server instance $($ServerInstance.ServerInstance)" -NoNewline
        Sync-NAVTenant -ServerInstance $ServerInstance.ServerInstance -Mode ForceSync -Force
        Write-Host " has been completed."
    }
}

# Example:
# Sync-NAVObject -Version "110"
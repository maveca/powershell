function Stop-NAVService($Version)
{
    $Version = $Version.SubString(0, $Version.length-1)
    # Stop NAV services
    $ServerInstances = Get-NAVServerInstance | Where-Object { ($_.Version -like "$Version.*") -and ($_.DisplayName -like 'Microsoft Dynamics NAV Server*') }
    foreach ($ServerInstance in $ServerInstances)
    {
        Stop-NAVServerInstance -ServerInstance $ServerInstance.ServerInstance
    }
}

# Example: 
# Stop-NAVService -Version "110"


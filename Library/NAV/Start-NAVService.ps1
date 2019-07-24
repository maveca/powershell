function Start-NAVService($Version)
{
    $Version = $Version.SubString(0, $Version.length-1)
    # Start NAV services
    $ServerInstances = Get-NAVServerInstance | Where-Object { ($_.Version -like "$Version.*") -and ($_.DisplayName -like 'Microsoft Dynamics NAV Server*') }
    foreach ($ServerInstance in $ServerInstances)
    {
        Start-NAVServerInstance -ServerInstance $ServerInstance.ServerInstance
    }
}

# Example
# Start-NAVService -Version "110"


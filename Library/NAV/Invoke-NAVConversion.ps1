function Invoke-NAVConversion ($DatabaseServer = "(local)", $DatabaseName, $LogPath)
{
    Write-Host "Database conversion of $DatabaseName" -NoNewline
    Invoke-NAVDatabaseConversion `
                -DatabaseName $DatabaseName `
                -DatabaseServer $DatabaseServer `
                -LogPath $LogPath
    Write-Host " has been completed."
}

# Example:
# Invoke-NAVConversion -DatabaseName "LOCAL_NAV_110_DEV" -LogPath "C:\temp"
function Remove-Database($ServerName = "(local)", $Database)
{
    try
    {
        $dbServer = New-Object Microsoft.SqlServer.Management.Smo.Server($ServerName)
        $dbServer.KillAllProcesses($Database)
        $dbServer.KillDatabase($Database)
        Write-Host "Drop of the database $Database on server $ServerName has been completed."
    } catch {
        Write-Warning $error[0]
    }
}

# Example:
# . ".\Library\SQL\Import-SQLModule.ps1"
# Import-SQLModule
# Remove-Database -Database "demodb"
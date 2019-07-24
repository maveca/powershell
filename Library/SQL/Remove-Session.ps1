function Remove-Sessions($con)
{
    try {
        $dbServer = New-Object Microsoft.SqlServer.Management.Smo.Server($con.Database)
        $dbServer.KillAllProcesses($con.DatabaseName)
        Write-Host "All connections from database $($con.DatabaseName) are dicsonnected."
    }
    catch {
        Write-Warning $error[0]
    }
}

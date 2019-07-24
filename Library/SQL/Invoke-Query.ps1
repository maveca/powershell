import-module SQLPS -DisableNameChecking;
function Invoke-Query($con, $query)
{
    try 
    {
        Write-ProgressBar "Runing query $query -ServerInstance $($con.Database) -Database $($con.DatabaseName)"
        Invoke-Sqlcmd -Query $query -ServerInstance $con.Database -Database $con.DatabaseName
    } catch {
        $error[0]|format-list –force
        return
    }
    Write-Host "Query $query has been completed."
    Write-Host ""
}


function Test-Database ($Server = "(local)", $Databse) {
    $DBName = (Invoke-Sqlcmd -Query "SELECT name FROM master.dbo.sysdatabases where name = '$Database'" -Server $Server).Name 
    return ($DBName -eq $Database)
}

# Example
# Test-Database -Databse "TMP_NAV_110_ORG"
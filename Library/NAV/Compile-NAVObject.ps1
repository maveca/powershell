function Invoke-NAVObjectCompilation($DatabaseServer = "(local)", $DatabaseName)
{
    Write-Host "Compiling objects $DatabaseName"
    'Page','Codeunit','Table','XMLport','Report' | ForEach-Object { Compile-NAVApplicationObject -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName -Filter "Type=$_" -AsJob } | Receive-Job -Wait
    Write-Host " has been completed."
}

# Example
# Invoke-NAVObjectCompilation -DatabaseName "NEW_NAV_110_DEV"

function Import-SQLModule
{
    Push-Location
    Import-Module SQLPS -DisableNameChecking | Out-Null
    Pop-Location
}

# Example
# Import-SQLModule
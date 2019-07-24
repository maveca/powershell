<#
    .SYNOPSIS
        Starts object in RTC mode.
    .DESCRIPTION        
        Starts RTC client and specific object.
    .PARAMETER ServerInstance
        Specifies NAV server instance.
    .PARAMETER Companyname
        Specifies company name where object is started. 
	.PARAMETER Port
        Specifies NAV server port for RTC client.
    .PARAMETER ObjectType
        Specifies object type.
    .PARAMETER ObjectID
        Specifies object id.
#>

function Start-NAVApplicationObjectInWindowsClient
{
    [cmdletbinding()]
    param(
        [string]$ServerName=[net.dns]::Gethostname(), 
        [int]$Port=7046, 
        [String]$ServerInstance, 
        [String]$Companyname,
        [ValidateSet('Table','Page','Report','Codeunit','Query','XMLPort')]
        [String]$ObjectType,
        [int]$ObjectID
         )
 
    $ConnectionString = "DynamicsNAV://$Servername" + ":$Port/$ServerInstance/$Companyname/Run$ObjectType"+"?$ObjectType=$ObjectID"
    Write-Verbose "Connectionstring: $ConnectionString ..."
    Start-Process $ConnectionString
}

<# Example:
Start-NAVApplicationObjectInWindowsClient `
    -ServerInstance ADACTA_NAV_110_TESTABILITY `
    -Companyname 'TESTABILITY International Ltd.' `
    -Port 7106 `
    -ObjectType Codeunit `
    -ObjectID 13051991 `
    -Verbose
#>

Export-ModuleMember Start-NAVApplicationObjectInWindowsClient
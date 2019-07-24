<#
    .SYNOPSIS
        Copies all objects in fob format from source database to destination.
    .DESCRIPTION        
        Copies all objects in fob format from source database to destination.
    .PARAMETER FromDatabaseServer
        Specifies source NAV datebase server
    .PARAMETER FromDatabaseName
        Specifies source NAV datebase name. 
	.PARAMETER ToDatabaseServer
        Specifies destination NAV database server.
    .PARAMETER ToDatabaseName
        Specifies destination NAV database name.
#>

function Copy-NAVApplicationDefinition
{
    [CmdletBinding()]
    param(
        [String]$FromDatabaseServer=[net.dns]::Gethostname(), 
        [Parameter(Mandatory=$True,Position=1)] [String]$FromDatabaseName,
        [String]$ToDatabaseServer=[net.dns]::Gethostname(), 
        [Parameter(Mandatory=$True,Position=2)] [String]$ToDatabaseName
    )
    Write-Verbose "Createing temp file."
    
    $FobTempFileName = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString() + '.fob'
    
    Write-Verbose "Importing Model Tools."
    Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -force -DisableNameChecking
    
    Write-Verbose "Exporting objects from $FromDatabaseName."
    Export-NAVApplicationObject $FobTempFileName -DatabaseServer $FromDatabaseServer –DatabaseName $FromDatabaseName
    
    Write-Verbose "Unlock objects on $ToDatabaseServer."
    Invoke-Sqlcmd -ServerInstance $ToDatabaseServer -Database $ToDatabaseName -Query @'
        UPDATE [Object] SET [Locked] = 0, [Locked By] = ''
'@
        
    Write-Verbose "Importing objects to $ToDatabaseName."
    Import-NAVApplicationObject $FobTempFileName -DatabaseServer $ToDatabaseServer –DatabaseName $ToDatabaseName –Confirm:$false -ImportAction Overwrite -SynchronizeSchemaChanges Force

    Write-Verbose "Deleting temporary file."
    Remove-Item -Path $FobTempFileName

    Write-Host "Objects have been copied from database $FromDatabaseName to $ToDatabaseServer."
}

<# Example: Copy-NAVApplicationDefinition -FromDatabaseName 'ADACTA_NAV_110_DEV' -ToDatabaseName 'ADACTA_NAV_110_TESTABILITY' -verbose #>

Export-ModuleMember Copy-NAVApplicationDefinition





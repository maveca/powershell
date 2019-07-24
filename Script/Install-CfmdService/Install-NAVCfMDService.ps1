# Unfinished!

# Parameters
# $ScriptRoot = Split-Path -Parent $PSCommandPath
# if($ScriptRoot -eq '') { $ScriptRoot = '.' }
Clear-Host
Push-Location
$CurrDir = "C:\Users\maveca\Desktop"
. $CurrDir\ProgressBar.ps1
$BackupFile = "C:\NAVDVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\110\Database\Demo Database NAV (11-0).bak"
$Database = "ADACTA_NAV_110_CfMD"
$ServerInstance = $Database

Import-Module "C:\Program Files\Microsoft Dynamics NAV\110\Service\NavAdminTool.ps1"
. $CurrDir\Database.ps1

# Restore W1 from DVD

Restore-Database -BackupFile $BackupFile -Database $Database
Invoke-Sqlcmd -Database $Database -Query @"
    USE [$Database]
    GO
    CREATE USER [SI\svc_NAVSRV] FOR LOGIN [SI\svc_NAVSRV]
    GO
    USE [$Database]
    GO
    ALTER USER [SI\svc_NAVSRV] WITH DEFAULT_SCHEMA=[dbo]
    GO
"@

Pop-Location

Get-NAVServerInstance

New-NAVServerInstance -ServerInstance $ServerInstance -ManagementServicesPort 7135 -ClientServicesPort 7136 -SOAPServicesPort 7137 -ODataServicesPort 7138 -DeveloperServicesPort 7139 `
                      -DatabaseServer 'navdev-lj-19' -DatabaseName $Database -ClientServicesCredentialType Windows

Remove-NAVServerInstance -ServerInstance $ServerInstance 

# New-Service -Name 'MicrosoftDynamicsNAVServer$$Database' -BinaryPathName '"C:\Program Files\Microsoft Dynamics NAV\110.19846\Service\Microsoft.Dynamics.Nav.Server.exe" $$Database /config "C:\Program Files\Microsoft Dynamics NAV\110.19846\Service\Instances\ADACTA_NAV_110_CfMD\Microsoft.Dynamics.NAV.Server.exe.config"' -DependsOn 'HTTP' -Description 'Service handling requests to Microsoft Dynamics NAV application.' -DisplayName 'Microsoft Dynamics NAV Server [ADACTA_NAV_110_CfMD]' -StartupType Manual

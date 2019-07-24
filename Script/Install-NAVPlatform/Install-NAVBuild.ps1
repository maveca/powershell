# Parameters
    # Source
        # Forward       
            $ver = '110'
            $oldver = '19394'
            $newver = '19846'
            $dvdurl = "http://download.microsoft.com/download/2/1/B/21B4FB9E-28B4-45D2-B744-E701EAFF542C/W1DVD.zip"
            $dvdzip = "\\si\dfs\DynamicsNAV\Client Install\1100\NAV2018 W1 CU1 (Build $newver)\NAV.11.0.$newver.W1.DVD.zip"
        # Backward 
        <#       
            $ver = '110'
            $oldver = '19846'
            $newver = '19394'
            $dvdurl = ""
            $dvdzip = "\\si\dfs\DynamicsNAV\Client Install\1100\NAV2018 W1 (Build 19394)\W1DVD.zip" 
        #>
    # Temporary folder
        $dvdfolder = "C:\NAVDVD" 
        $tmpPath = 'C:\Temp'
        $skipFileDownload = $false
    # Destination service must be local
        $DatabaseName = 'LOCAL_NAV_110_DEV'
        $SqlServerInstance = 'NB-01-SANDIM'
        $DatabaseBackupFilePath = "${env:ProgramFiles}\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\DynamicsNAV110.bak"
    $sw = [Diagnostics.Stopwatch]::StartNew()
    Write-Host "Started technical upgrade from $oldver to $newver."

# Load needed modules
    Push-Location
    Import-Module "${env:ProgramFiles}\\Microsoft Dynamics NAV\$ver\Service\NavAdminTool.ps1"
    Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1"
    $NavIde = "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver\RoleTailored Client\finsql.exe"
    Write-Verbose "Global variable NAVIDE is set to $NavIde."
    Import-Module Sqlps -DisableNameChecking
    import-module WebAdministration
    Pop-Location

# Test Administrator rights
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}


# Download zip file and unpack to $dvdfolder
    if (Test-Path "$dvdfolder\setup.exe"){
        if (((Get-Item C:\NAVDVD\setup.exe).VersionInfo.FileVersion -split '\.')[2] -eq $newver) {
            $skipFileDownload = $true
        }
    }
    if (-not $skipFileDownload){
        IF (-not (Test-Path $dvdzip)) {
            (New-Object Net.WebClient).DownloadFile($dvdurl,"$tmpPath\W1DVD.zip")
        }
        else
        {
            Copy-Item -Path $dvdzip -Destination "$tmpPath\W1DVD.zip" -Force
        }
        if (Test-Path $dvdfolder){
            Remove-Item -Path $dvdfolder -Recurse -Force
        }
        New-Item -Path $dvdfolder -ItemType Directory -Force
        (New-object -com Shell.Application).namespace("$dvdfolder").CopyHere((new-object -com shell.application).namespace("$tmpPath\W1DVD.zip").Items(),16) 
        Remove-Item  "$tmpPath\W1DVD.zip" -Force
    }


# Prepare database for upgrade
    # Remove Connections to the database
    Invoke-Sqlcmd "USE [master]
                    DECLARE @id INTEGER
                    DECLARE @sql NVARCHAR(200)
                    WHILE EXISTS(SELECT * FROM master..sysprocesses WHERE dbid = DB_ID(N'$DatabaseName'))
                    BEGIN
                        SELECT TOP 1 @id = spid FROM master..sysprocesses WHERE dbid = DB_ID(N'$DatabaseName')
                        SET @sql = 'KILL '+RTRIM(@id) 
                        EXEC(@sql)  
                    END" -ServerInstance $SqlServerInstance

    # Backup database
    Invoke-Sqlcmd "BACKUP DATABASE `"$DatabaseName`" TO DISK = '$DatabaseBackupFilePath'" `
                -ServerInstance $SqlServerInstance -QueryTimeout 0

    # Unlock all objects
    Invoke-Sqlcmd `
                -Query "Update obj Set obj.Locked = 0, obj.[Locked By] = '' from Object obj where Locked = 1" `
                -ServerInstance $SqlServerInstance  `
                -Database $DatabaseName

    Set-Location $CurrentLocation

    # Recompile database and synchronize objects to the table
    Compile-NAVApplicationObject -DatabaseServer $SqlServerInstance -DatabaseName $DatabaseName -LogPath $tmpPath -Filter "Compiled=No"


# Stop NAV services
$ServerInstances = Get-NAVServerInstance | Where-Object -Property 'Version' -eq '11.0.19846.0' 
foreach ($ServerInstance in $ServerInstances)
{
    #$ServiceName = $ServerInstance.ServerInstance.SubString($ServerInstance.ServerInstance.IndexOf("$")+1)
    Sync-NAVTenant -ServerInstance $ServerInstance.ServerInstance -Mode Sync -Force
    Stop-NAVServerInstance -ServerInstance $ServerInstance.ServerInstance
}


# Remove Web Service Instances
    # Load web server applications into array
    $webservers = @()
    foreach ($ws in get-childitem IIS:\Sites)
    {
        $wa = Get-WebApplication -Site $ws.Name
        foreach ($a in $wa)
        {
            $webserver = Get-NAVWebServerInstance -WebServerInstance ($a.path).Substring(1)
            $webservers += $webserver
        }
    }
    # Delete web applications
    foreach ($webserver in $webservers)
    {
        Remove-NAVWebServerInstance -WebServerInstance $webserver.WebServerInstance -SiteDeploymentType SubSite
    }

# Copy Server files
    # NAV Server
    if (-not (Test-Path "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$newver")) {
        New-Item -ItemType directory -Path "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$newver"

        Copy-Item "$dvdfolder\ServiceTier\program files\Microsoft Dynamics NAV\$ver\Service" -Destination "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$newver" -Recurse -Force
        Copy-Item "$dvdfolder\WebClient\Microsoft Dynamics NAV\$ver\Web Client" -Destination "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$newver" -Recurse -Force
        

        if (Test-Path "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$oldver\Service\Translations") {
            Copy-Item "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$oldver\Service\Translations" -Destination "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$newver\Service" -Recurse -Force
        }
        if (Test-Path "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$oldver\Service\Instances") {
            Copy-Item "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$oldver\Service\Instances" -Destination "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$newver\Service" -Recurse -Force
        }
        Copy-Item "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$oldver\Service\*.config" -Destination "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$newver\Service" -Force
    }
    # Delete Pervious link
    if (-not (Test-Path "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$oldver")) {
        Rename-Item "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver" -NewName "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$oldver" -Force
    } else {
        Remove-Item -Path "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver" -Force -Recurse
        [io.directory]::Delete("${env:ProgramFiles}\Microsoft Dynamics NAV\$ver")
    }
    # Create Linked Path
    New-Item -Path "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver" -ItemType SymbolicLink -Value "${env:ProgramFiles}\Microsoft Dynamics NAV\$ver.$newver"

# Copy Client files
    if (-not (Test-Path "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$newver")) {
        New-Item -ItemType directory -Path "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$newver"

        Copy-Item "$dvdfolder\RoleTailoredClient\program files\Microsoft Dynamics NAV\$ver\RoleTailored Client" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$newver" -Recurse -Force
        Copy-Item "$dvdfolder\ADCS\program files\Microsoft Dynamics NAV\$ver\Automated Data Capture System" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$newver" -Recurse -Force
        Copy-Item "$dvdfolder\ClickOnceInstallerTools\Program Files\Microsoft Dynamics NAV\$ver\ClickOnce Installer Tools" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$newver" -Recurse -Force
        Copy-Item "$dvdfolder\ModernDev\Program Files\Microsoft Dynamics NAV\$ver\Modern Development Environment" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$newver" -Recurse -Force
        Copy-Item "$dvdfolder\Outlook\Program Files\Microsoft Dynamics NAV\$ver\OutlookAddin" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$newver" -Recurse -Force
    }
    # Delete Pervious link
    if (-not (Test-Path "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$oldver")) {
        Rename-Item "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver" -NewName "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$oldver" -Force
    } else {
        Remove-Item -Path "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver" -Force -Recurse
        [io.directory]::Delete("${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver")
    }
    # Create Linked Path
    New-Item -Path "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver" -ItemType SymbolicLink -Value "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$ver.$newver"

# Database Technical Conversion...
    Invoke-NAVDatabaseConversion `
                -DatabaseName $DatabaseName `
                -DatabaseServer $SqlServerInstance `
                -LogPath $tmpPath

    # For full upgrade you should import here UpgradeToolkit.fob file  
 
# Start NAV Services
foreach ($ServerInstance in $ServerInstances)
{
    Start-NAVServerInstance -ServerInstance $ServerInstance.ServerInstance
    Sync-NAVTenant -ServerInstance $ServerInstance.ServerInstance -Mode Sync -Force
}
    
    
# Install web server instances
foreach ($webserver in $webservers)
{
    New-NAVWebServerInstance -Server $webserver.Server -ServerInstance $webserver.ServerInstance -SiteDeploymentType $webserver.SiteDeploymentType -ClientServicesPort $webserver.ClientServicesPort -WebServerInstance $webserver.WebServerInstance -WebSitePort $webserver.WebSitePort
}

$sw.Stop()
Write-Host "Finished with technical upgrade from $oldver to $newver."
Write-Host "Time elapsed: "$sw.Elapsed


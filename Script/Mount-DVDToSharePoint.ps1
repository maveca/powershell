# Start folder
    New-Item -Path "D:\Temp" -Name "SharePoint" -ItemType Directory -Force

# Version.txt
    $VerContent = @"
Product Name: Microsoft Dynamics NAV
Version: 2018
Cumulative Update: 2
Build Number: 110.20348
"@
    
    $VerContent | Out-File -FilePath "D:\Temp\SharePoint\Version.txt" -Force

# W1.DVD.zip
    Copy-Item -Path "D:\Temp\DVD\MOD\NAV.11.0.20348.W1.DVD.zip" -Destination "D:\Temp\SharePoint\W1.DVD.zip"


# W1.CU.zip
    New-Item -Path "D:\Temp\SharePoint" -Name "W1.CU" -ItemType Directory -Force
    New-Item -Path "D:\Temp\SharePoint\W1.CU" -Name "Server" -ItemType Directory -Force
    New-Item -Path "D:\Temp\SharePoint\W1.CU" -Name "Client" -ItemType Directory -Force
    Copy-Item -Path "D:\Temp\DVD\MOD\NAVDVD\ServiceTier\program files" -Destination "D:\Temp\SharePoint\W1.CU\Server" -Recurse
    Copy-Item -Path "D:\Temp\DVD\MOD\NAVDVD\RoleTailoredClient\program files" -Destination "D:\Temp\SharePoint\W1.CU\Client" -Recurse
    Copy-Item -Path "D:\Temp\DVD\MOD\NAVDVD\ADCS\program files" -Destination "D:\Temp\SharePoint\W1.CU\Client" -Recurse -Force
    Copy-Item -Path "D:\Temp\DVD\MOD\NAVDVD\ClickOnceInstallerTools\program files" -Destination "D:\Temp\SharePoint\W1.CU\Client" -Recurse -Force
    Copy-Item -Path "D:\Temp\DVD\MOD\NAVDVD\Outlook\program files" -Destination "D:\Temp\SharePoint\W1.CU\Client" -Recurse -Force
    Copy-Item -Path "D:\Temp\DVD\MOD\NAVDVD\ModernDev\program files" -Destination "D:\Temp\SharePoint\W1.CU\Client" -Recurse -Force

    Add-Type -Assembly "System.IO.Compression.FileSystem"
    [System.IO.Compression.ZipFile]::CreateFromDirectory("D:\Temp\SharePoint\W1.CU", "D:\Temp\SharePoint\W1.CU.zip")

    Remove-Item -Path "D:\Temp\SharePoint\W1.CU" -Recurse -Force

# AD.SQL.zup
    . ".\Library\SQL\Import-SQLModule.ps1"
    Import-SQLModule 
    . ".\Library\SQL\Backup-Database.ps1"
    Remove-Item -Path "D:\MSSQL\Backup\ADACTA_NAV_110_BLD.bak" -Force
    Backup-Database -ServerName "navdev-lj-19" -Database "ADACTA_NAV_110_BLD" -BackupFile "D:\MSSQL\Backup\ADACTA_NAV_110_BLD.bak"
    New-Item -Path "D:\Temp\SharePoint" -Name "AD.SQL" -ItemType Directory -Force
    Copy-Item -Path "D:\MSSQL\Backup\ADACTA_NAV_110_BLD.bak" -Destination "D:\Temp\SharePoint\AD.SQL" -Recurse
    Add-Type -Assembly "System.IO.Compression.FileSystem"
    [System.IO.Compression.ZipFile]::CreateFromDirectory("D:\MSSQL\Backup\AD.SQL", "D:\Temp\SharePoint\AD.SQL.zip")
    Remove-Item -Path "D:\Temp\SharePoint\AD.SQL\ADACTA_NAV_110_BLD.bak" -Force


# AD.TEST
    . ".\Library\NAV\Use-NAVDVD.ps1"
    Import-NavModelTool -BUILDbinaries "C:\Program Files (x86)\Microsoft Dynamics NAV\110.20348\RoleTailored Client"
    . ".\Library\NAV\Export-NAVObject.ps1"
    Export-NAVObject -VersionNo "110" -DatabaseName "ADACTA_NAV_110_DEV" -ExportFile "D:\Temp\SharePoint\AD.BUILD.Testability.fob" -OutputFolder "C:\temp"

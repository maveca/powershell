function Install-NAVPlatform($WorkingFolder) # $WorkingFolder = "D:\Temp"
{
    # Test if working folder exists!
    if (-not (Test-Path -Path $WorkingFolder))
    {
        Write-Error "Working folder $WorklingFolder does not exist."
        break script
    }

    # Get urls for last two dvds
        #TODO: Use Web Library Get-VersionMap to get URL for downloading...
        $W1DVDOrg = "https://download.microsoft.com/download/3/5/3/353B5669-042D-4EE2-B76A-13D9A1A0621D/CU 01 NAV 2018 W1.zip"
        $W1DVDMod = "https://download.microsoft.com/download/C/3/C/C3C91857-0DB6-4619-A386-BF9D779F705E/CU 02 NAV 2018 W1.zip"    

    # Copy last two dvds from web.
        . ".\Library\WEB\Copy-WebItem.ps1"
        Copy-WebItem -ItemURL $W1DVDOrg "$WorkingFolder\DVD\ORG.zip"
        Copy-WebItem -ItemURL $W1DVDMod "$WorkingFolder\DVD\MOD.zip"

    # Extract zip files
        . ".\Library\CMD\Use-ZIPFile.ps1"
        Restore-NAVDVD -WorkingFolder $WorkingFolder -SubFolder "DVD\ORG"
        Restore-NAVDVD -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD"

    # Stop web services and remove all web sites.
        . ".\Library\NAV\Use-NAVDVD.ps1"
        Import-NavAdminTool (Get-NAVSVCFolder -WorkingFolder "$WorkingFolder\DVD" -SubFolder "MOD" -Version "110")
        . ".\Library\NAV\Stop-NAVService.ps1"
        Stop-NAVService -Version "110"
        . ".\Library\NAV\Install-NAVWebService2.ps1"
        $wscs = Uninstall-NAVWebService

    
    # Copy platform server and client files
        . ".\Library\NAV\Copy-NAVServerFiles.ps1"
        Copy-NAVServerFiles -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD" -Version "110"
        . ".\Library\NAV\Copy-NAVClientFiles.ps1"
        Copy-NAVClientFiles -WorkingFolder $WorkingFolder -SubFolder "DVD\MOD" -Version "110"


    # Convert database
        . ".\Library\NAV\Use-NAVDVD.ps1"
        Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder "$WorkingFolder\DVD" -SubFolder "MOD" -Version "110")
        . ".\Library\NAV\Invoke-NAVConversion.ps1"
        foreach($ws in $wscs)
        {
            Invoke-NAVConversion -DatabaseName $ws -LogPath $WorkingFolder
        }

    # Start services and install back all web sites
        . ".\Library\NAV\Start-NAVService.ps1"
        Start-NAVService -Version "110"
        Install-NAVWebService -webservers $wscs
}

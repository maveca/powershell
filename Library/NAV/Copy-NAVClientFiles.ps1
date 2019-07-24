function Copy-NAVClientFiles($WorkingFolder, $SubFolder, $Version)
{
    Copy-Item "$WorkingFolder\$SubFolder\NAVDVD\RoleTailoredClient\program files\Microsoft Dynamics NAV\$Version\RoleTailored Client" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$Version" -Recurse -Force
    Copy-Item "$WorkingFolder\$SubFolder\NAVDVD\ADCS\program files\Microsoft Dynamics NAV\$Version\Automated Data Capture System" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$Version" -Recurse -Force
    Copy-Item "$WorkingFolder\$SubFolder\NAVDVD\ClickOnceInstallerTools\Program Files\Microsoft Dynamics NAV\$Version\ClickOnce Installer Tools" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$Version" -Recurse -Force
    Copy-Item "$WorkingFolder\$SubFolder\NAVDVD\ModernDev\Program Files\Microsoft Dynamics NAV\$Version\Modern Development Environment" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$Version" -Recurse -Force
    Copy-Item "$WorkingFolder\$SubFolder\NAVDVD\Outlook\Program Files\Microsoft Dynamics NAV\$Version\OutlookAddin" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$Version" -Recurse -Force
    
    Copy-Item "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$Version" -Destination "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\$Version.20348" -Recurse -Force
}

# Example:
# Copy-NAVClientFiles -WorkingFolder "C:\temp\DVD" -SubFolder "MOD" -Version "110"



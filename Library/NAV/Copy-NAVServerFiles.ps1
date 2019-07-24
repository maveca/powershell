function Copy-NAVServerFiles($WorkingFolder, $SubFolder, $Version)
{
    Copy-Item "$WorkingFolder\$SubFolder\NAVDVD\ServiceTier\program files\Microsoft Dynamics NAV\$Version\Service" -Destination "${env:ProgramFiles}\Microsoft Dynamics NAV\$Version" -Recurse -Exclude "*.config" -Force
    Copy-Item "$WorkingFolder\$SubFolder\NAVDVD\WebClient\Microsoft Dynamics NAV\$Version\Web Client" -Destination "${env:ProgramFiles}\Microsoft Dynamics NAV\$Version" -Recurse -Force

    Copy-Item "${env:ProgramFiles}\Microsoft Dynamics NAV\$Version" -Destination "${env:ProgramFiles}\Microsoft Dynamics NAV\$Version.20348" -Recurse -Force
}

# Example:
# Copy-NAVServerFiles -WorkingFolder "C:\temp\DVD" -SubFolder "MOD" -Version "110"
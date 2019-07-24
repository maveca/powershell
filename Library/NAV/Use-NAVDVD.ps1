function Get-NAVRTCFolder($WorkingFolder, $SubFolder, $Version)
{
    $result = (Join-Path $WorkingFolder $SubFolder) + "\NAVDVD\RoleTailoredClient\program files\Microsoft Dynamics NAV\" + $Version + "\RoleTailored Client"
    if (!(Test-Path -Path $result))
    {
        Write-Error "Folder $result does not exits."
    }

    return $result
}

function Get-NAVSVCFolder($WorkingFolder, $SubFolder, $Version)
{
    
    $result = (Join-Path $WorkingFolder $SubFolder) + "\NAVDVD\ServiceTier\program files\Microsoft Dynamics NAV\" + $Version + "\Service"
    if (!(Test-Path -Path $result))
    {
        Write-Error "Folder $result does not exits."
    }

    return $result
}

function Get-NAVDBFolder($WorkingFolder, $SubFolder, $Version)
{
    $result = (Join-Path $WorkingFolder $SubFolder) + "\NAVDVD\SQLDemoDatabase\CommonAppData\Microsoft\Microsoft Dynamics NAV\"+$Version+"\Database"
    if (!(Test-Path -Path $result))
    {
        Write-Error "Folder $result does not exits."
    }
    return $result
}

function Get-NAVDBBackupFile($WorkingFolder, $SubFolder, $Version)
{
    $result = (Get-NAVDBFolder -WorkingFolder $WorkingFolder -SubFolder $SubFolder -Version $Version) 
    $result = $result + "\" + (Get-ChildItem -Path $result -File -Include "*.bak" -Recurse | Select-Object -First 1).Name
    if (!(Test-Path -Path $result))
    {
        Write-Error "Backup file $result does not exits."
    }
    return $result
}

function Import-NavModelTool($BUILDbinaries)
{
    if(Test-Path $BUILDbinaries)
    {
        $ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
        $NavModelTools = Get-ChildItem -Path $BUILDbinaries -File -Include "NavModelTools.ps1" -Recurse | Sort-Object $ToNatural | Select-Object -Last 1
    }
    if ([string]::IsNullOrEmpty($NavModelTools.FullName))
    {
        Write-Warning "Unable to find NavModelTools.ps1 under: $BUILDbinaries"
    }
    Import-Module $NavModelTools.FullName | Out-Null
    $global:NavIde =  Get-ChildItem -Path $BUILDbinaries -File -Include "finsql.exe" -Recurse | Sort-Object $ToNatural | Select-Object -Last 1
    Write-Verbose "Global variable NavIde is set to $global:NavIde"
}
function Import-NavAdminTool($BUILDbinaries)
{
    if(Test-Path $BUILDbinaries)
    {
        $ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
        $NavAdminTool = Get-ChildItem -Path $BUILDbinaries -File -Include "NavAdminTool.ps1" -Recurse | Sort-Object $ToNatural | Select-Object -Last 1
    }
    if ([string]::IsNullOrEmpty($NavAdminTool.FullName))
    {
        Write-Warning "Unable to find NavAdminTool.ps1 under: $BUILDbinaries"
    }
    Import-Module $NavAdminTool.FullName | Out-Null
}

# Example:
# Get-NAVDBBackupFile -WorkingFolder "C:\temp" -SubFolder "ORG" -Version "110"
# Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder "C:\temp\DVD" -SubFolder "ORG" -Version "110")
# Import-NavAdminTool (Get-NAVSVCFolder -WorkingFolder "C:\temp\DVD" -SubFolder "MOD" -Version "110")
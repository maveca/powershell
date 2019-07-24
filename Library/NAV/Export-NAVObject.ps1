function Export-NAVObject($VersionNo, $DatabaseServer = "(local)", $DatabaseName, $ExportFile, $OutputFolder, $filter = "")
{
    if ([string]::IsNullOrEmpty($ExportFile) -or (Test-Path -Path $ExportFile -PathType Leaf))
    {
        Write-Warning "Exporting objects are skipped beacuse $ExportFile already exists."
        return
    }
    if (Test-Path -Path "$env:APPDATA\fin.zup")
    {
        # Delete default zup file before exporting. This will prevent from error:
        # [0] The Server Instance specified in the Options window is not available for this
        # database. You must choose an instance to use before performing this activity. Do you
        # want to do this now?
        Remove-Item -Path "$env:APPDATA\fin.zup" -Force | Out-Null
    }
    if(Export-NAVSupportedVersion -VersionNo $VersionNo)
    {
        Write-Host "Exporting objects to $ExportFile."
        Export-NAVApplicationObject -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName -Path $ExportFile -ExportTxtSkipUnlicensed -LogPath $OutputFolder -Filter "$filter" | Out-Null
    }
    else
    {
        Write-Host "Exporting objects directly to $ExportFile."
        Export-NAVObjectDirect $DatabaseServer $DatabaseName $ExportFile $OutputFolder $filter
    }
}

function Export-NAVSupportedVersion($VersionNo)
{
    if ($VersionNo -eq "70") { return $false }
    if ($VersionNo -eq "71") { return $false }
    return $true
}

function Export-NAVObjectDirect
{
    [CmdletBinding()]
    param (
        [String]$Server = '.',
        [String]$Database,
        [String]$ExportFile,
        [String]$WorkingFolder,
        [String]$Filter = ''
          )
 
    $LogFile = $ExportFile+".log"
    Remove-File "$WorkingFolder\navcommandresult.txt"
    Remove-File $ExportFile
 
    $exportfinsqlcommand = "`"$NavIde`" command=exportobjects,file=`"$ExportFile`",servername=$Server,database=$Database,Logfile=`"$LogFile`""
 
    if ($Filter -ne "")
        {$exportfinsqlcommand = "$exportfinsqlcommand,filter=`"$Filter`""}
 
    $Command = $exportfinsqlcommand
    Write-Host $Command
    Write-Debug $Command
    cmd /c $Command
 
    $ExportFileExists = Test-Path "$ExportFile"
    If (-not $ExportFileExists) 
    {
            write-error "Error on exporting to $ExportFile.  Look at the information below."
            if (Test-Path "$WorkingFolder\navcommandresult.txt"){Get-Content "$WorkingFolder\navcommandresult.txt"}
            if (Test-Path $LogFile) {Get-Content $LogFile}
    }
    else
    {
        $NAVObjectFile = Get-ChildItem $ExportFile
        if ($NAVObjectFile.Length -eq 0)
        {
            Remove-Item $NAVObjectFile
        } 
 
        if (Test-Path "$WorkingFolder\navcommandresult.txt")
        {
            Get-Content "$WorkingFolder\navcommandresult.txt"
        }
    }
}

# Example:
# . ".\Library\NAV\Use-NAVDVD.ps1"
# Import-NavModelTool -BUILDbinaries "C:\Program Files (x86)\Microsoft Dynamics NAV\110.20348\RoleTailored Client"
# . ".\Library\NAV\Export-NAVObject.ps1"
# Export-NAVObject -VersionNo "110" -DatabaseName "NEW_NAV_110_DEV" -ExportFile "C:\temp\all.fob" -OutputFolder "C:\temp"

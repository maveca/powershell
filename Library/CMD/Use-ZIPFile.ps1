function Restore-ZIPFile($ZIPFile, $DestinationFolder, $RemoveZIPAfter = $false) 
{
    if (Test-Path -Path $DestinationFolder)
    {
        Remove-Item -Path $DestinationFolder -Recurse -Force
    }
    New-Item -Path $DestinationFolder -ItemType Directory -Force
    (New-object -com Shell.Application).namespace("$DestinationFolder").CopyHere((new-object -com shell.application).namespace("$ZIPFile").Items(),16) 
    if ($RemoveZIPAfter)
    {
        Remove-Item  "$tmpPath\W1DVD.zip" -Force
    }
}

function Restore-NAVDVD($WorkingFolder, $SubFolder)
{
    if (-not(Test-Path -Path (Join-Path (Join-Path $WorkingFolder $SubFolder) "NAVDVD")))
    {
        Restore-ZIPFile -ZIPFile "$WorkingFolder\$SubFolder.zip" "$WorkingFolder\$SubFolder"
        Restore-ZIPFile -ZIPFile "$WorkingFolder\$SubFolder\$((Get-ChildItem -Path "$WorkingFolder\$SubFolder" -File -Include "*.zip" -Recurse | Select-Object -First 1).Name)" "$WorkingFolder\$SubFolder\NAVDVD"
    }
    else {
        Write-Warning "File $(Join-Path (Join-Path $WorkingFolder $SubFolder) "NAVDVD") is already extracted."
    }
}

function Compress-ZIPFile($SourceFolder, $ZIPFile, $RemoveSourceAfter = $false)
{
    #Not implemented yet.
}

# Example:
# Restore-ZIPFile -ZIPFile "C:\temp\W1DVD.zip" "C:\temp\W1DVD"
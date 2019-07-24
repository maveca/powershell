function Merge-NAVObject ($WorkingFolder, $OriginalPath, $ModifiedPath, $TargetPath, $ResultPath) 
{
    if (-not (Test-Path (Join-Path $WorkingFolder $ResultPath)))
    {
        New-Item -Path $WorkingFolder -Name $ResultPath -ItemType Directory 
        Merge-NAVApplicationObject -OriginalPath $(Join-Path $WorkingFolder $OriginalPath) -ModifiedPath $(Join-Path $WorkingFolder $ModifiedPath) -TargetPath (Join-Path $WorkingFolder $TargetPath) -ResultPath (Join-Path $WorkingFolder $ResultPath)
    }
    else
    {
        Write-Warning "Merged results already exists on location: $(Join-Path $WorkingFolder $ResultPath)"
    }
}
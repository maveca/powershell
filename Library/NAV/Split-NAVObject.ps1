function Split-NAVObject($SourceFile, $WorkingFolder, $SubFolder)
{
    if (Test-Path -Path  "$WorkingFolder\$SubFolder\navcommandresult.txt")
    {
        Remove-Item -Path "$WorkingFolder\$SubFolder\navcommandresult.txt" -Force
    }
    
    if ((Get-ChildItem -Path "$WorkingFolder\$SubFolder\*.txt").Count -eq 0)
    {
        Write-Host "Splitting $SourceFile to $("$WorkingFolder\$SubFolder")" -NoNewLine
        New-Item -Path $("$WorkingFolder") -Name $SubFolder -ItemType Directory -Force | Out-Null
        Split-NAVApplicationObjectFile -Source $SourceFile -Destination $("$WorkingFolder\$SubFolder")
        Write-Host " has been complited."
    }
    else {
        Write-Warning "Splitting is skiped because $("$WorkingFolder\$SubFolader") already exists."
    }
}

# Example:
# Split-NAVObject -SourceFile $("$WorkingFolder\CODE\ORG-All.txt") -WorkingFolder $("$WorkingFolder\CODE") -SubFolder "ORG"

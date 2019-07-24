function Join-NAVObject($WorkingFolder, $SubFolder, $ResultFile)
{
    if (-not (Test-Path -Path $("$WorkingFolder\$ResultFile")))
    {
        Write-Host "Joining $("$WorkingFolder\$SubFolder") to $("$WorkingFolder\$ResultFile")" -NoNewline
        New-Item -Path $("$WorkingFolder") -Name $SubFolder -ItemType Directory -Force | Out-Null
        Join-NAVApplicationObjectFile -Source $("$WorkingFolder\$SubFolder\*.txt") -Destination $("$WorkingFolder\$ResultFile") | Out-Null
        Write-Host " has been completed."
    }
    else {
        Write-Warning "Joining is skiped because $("$WorkingFolder\$ResultFile") already exists."
    }
}

# Example
# Join-NAVObject -WorkingFolder "C:\temp\CODE" -SubFolder "RES" -ResultFile "RES-All.txt"
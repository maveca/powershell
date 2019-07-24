
function Compare-NAVObject($WorkingFolder, $OriginalFolder, $ModifiedFolder)
{
    if (-not (Test-Path -Path $("$WorkingFolder\CODE\$ModifiedFolder\DEL")))
    {
        Write-Host "Comparing $OriginalFolder and $ModifiedFolder folder." -NoNewline
        New-Item -Path $("$WorkingFolder\CODE\$ModifiedFolder") -Name 'DEL' -ItemType Directory -Force | Out-Null
        Compare-NAVApplicationObject -OriginalPath "$WorkingFolder\CODE\$OriginalFolder" -ModifiedPath "$WorkingFolder\CODE\$ModifiedFolder" -DeltaPath "$WorkingFolder\CODE\$ModifiedFolder\DEL\"
        Write-Host " has been completed."
    } else {
        Write-Warning "Comparing is skiped because $("$WorkingFolder\CODE\$ModifiedFolder\DEL") already exists."
    }
}

# Example:
# Compare-NAVObject -WorkingFolder "C:\temp" -OriginalFolder "TAR" -ModifiedFolder "DEV" 


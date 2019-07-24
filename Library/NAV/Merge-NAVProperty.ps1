function Merge-NAVObjectProperty ($ModifiedPath, $TargetPath, $ResultPath) {
    # Skip if any of file is missing
    if (-not(Test-Path $ModifiedPath) -or -not(Test-Path $TargetPath) -or -not(Test-Path $ResultPath)){
        return
    }
    # Collect properties for Modified
    $ModVer = (Get-NAVApplicationObjectProperty -Source $ModifiedPath).VersionList
    $ModDateTime = [datetime]::ParseExact(((Get-NAVApplicationObjectProperty -Source $ModifiedPath).Date + " " + (Get-NAVApplicationObjectProperty -Source $ModifiedPath).Time), "dd.MM.yy HH:mm:ss", $null)
    # Collect properties for Target
    $TarVer = (Get-NAVApplicationObjectProperty -Source $TargetPath).VersionList
    $TarDateTime = [datetime]::ParseExact(((Get-NAVApplicationObjectProperty -Source $TargetPath).Date + " " + (Get-NAVApplicationObjectProperty -Source $TargetPath).Time), "dd.MM.yy HH:mm:ss", $null)
    # Calculate properties for Result
    $ResVerArray = $TarVer.Split(",")
    $ResVerArray[0] = $ModVer.Split(",")[0]
    $ResVer = $ResVerArray -join ","
    $ResultDate = ($ModDateTime, $TarDateTime | Measure-Object -Maximum).Maximum.ToString("dd.MM.yy")
    $ResultTime = ($ModDateTime, $TarDateTime | Measure-Object -Maximum).Maximum.ToString("HH.mm.ss")
    if ($ResultTime -ne "12:00:00")
    {
        $ResultTime = "23:00:00"
    }
    # Set result    

    Set-NAVApplicationObjectProperty -TargetPath $ResultPath -VersionListProperty $ResVer -DateTimeProperty ($ResultDate + " " + $ResultTime)
}

function Merge-NAVProperty ($WorkingPath, $ModifiedPath, $TargetPath, $ResultPath) {
    $files = Get-ChildItem -Path (Join-Path $WorkingPath $ResultPath) -Recurse -Include *.txt
    ForEach ($file in $files)
    {
        Merge-NAVObjectProperty `
            -ModifiedPath (Join-Path (Join-Path $WorkingPath $ModifiedPath) $file.Name) `
            -TargetPath (Join-Path (Join-Path $WorkingPath $TargetPath) $file.Name) `
            -ResultPath (Join-Path (Join-Path $WorkingPath $ResultPath) $file.Name)
    }
}

# . ".\Library\NAV\Use-NAVDVD.ps1"
# Import-NavModelTool (Get-NAVRTCFolder -WorkingFolder "C:\temp" -SubFolder "DVD\ORG" -Version "110") | Out-Null
# Merge-NAVObjectProperty -ModifiedPath "C:\Temp\TTS\MOD\COD138000.TXT" -TargetPath "C:\Temp\TTS\TAR\COD138000.TXT" -ResultPath "C:\Temp\TTS\RES\COD138000.TXT"
# Merge-NAVProperty -WorkingPath "C:\Temp\TTS" -ModifiedPath "MOD" -TargetPath "TAR" -ResultPath "RES"
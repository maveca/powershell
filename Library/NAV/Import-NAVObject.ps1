function Import-NAVObject($VersionNo, $DatabaseServer = "(local)", $DatabaseName, $ImportFile, $OutputFolder)
{
    $MarkPath = "$OutputFolder\$(Split-Path $ImportFile -leaf).ok"
    if ([string]::IsNullOrEmpty($ImportFile) -or (Test-Path -Path $MarkPath -PathType Leaf))
    {
        Write-Warning "Importing objects are skipped beacuse $MarkPath already exists."
        return
    }
    if (Test-Path -Path "$env:APPDATA\fin.zup")
    {
        # Delete default zup file before Importing. This will prevent from error:
        # [0] The Server Instance specified in the Options window is not available for this
        # database. You must choose an instance to use before performing this activity. Do you
        # want to do this now?
        Remove-Item -Path "$env:APPDATA\fin.zup" -Force | Out-Null
    }
    try {
        Write-Host "Importing objects from $ImportFile to $DatabaseName..."
        Import-NAVApplicationObject -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName -Path $ImportFile -ImportAction "Overwrite" -LogPath $OutputFolder -SynchronizeSchemaChanges No -Confirm:$false
        Write-Host "Importing has been completed."
        "File has been imported" | Out-File -FilePath $MarkPath -Append 
    }
    catch {
        Write-Host ""
        Write-Warning $error[0]
    }
}
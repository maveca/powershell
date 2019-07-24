function Copy-WebItem($ItemURL, $DestinationFile) {
    IF (-not (Test-Path $DestinationFile)) {
        Write-Host "Downloading file $ItemURL to $DestinationFile ..."
        (New-Object Net.WebClient).DownloadFile($ItemURL, $DestinationFile)
    }
    else {
        Write-Warning "File $DestinationFile is already downloaded."        
    }
}

# Example:
# Copy-WebItem -ItemURL "http://download.microsoft.com/download/2/1/B/21B4FB9E-28B4-45D2-B744-E701EAFF542C/W1DVD.zip" -DestinationFile "c:\temp\W1DVD.zip" 
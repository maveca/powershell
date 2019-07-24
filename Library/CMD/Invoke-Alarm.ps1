function Invoke-Alarm(){
    for ($i=1; $i -lt 5; $i++){
        [console]::beep(500,300)
        Start-Sleep -Milliseconds 100
        [console]::beep(500,500)
        Start-Sleep -Milliseconds 300
    }
    [console]::beep(1000,1000)    
}

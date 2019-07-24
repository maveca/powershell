$progress = @("Title", "Activity", 0, 100)
$Time = [System.Diagnostics.Stopwatch]::StartNew()

function Start-ProgressBar($Title)
{
    $progress[0] = $Title
    Clear-Host
    Write-Host "Starting $Title process..."
    $Time = [System.Diagnostics.Stopwatch]::StartNew()
}

function Stop-ProgressBar
{
    if ($progress[2] -ne $progress[3])
    {
        Write-Warning "Progress Bar: Total count does not match last progress index. Please correct your script."
        Write-Host "Last progress index is $($progress[2])"
    }
    Write-Host "Total elapsed time is $($Time.Elapsed.ToString())"
    Write-Host "$($progress[0]) process has been finished."
}


function Set-ProgressBarActivity($Status)
{
    $progress[1] = $Status
}

function Set-ProgressBarIndex([int]$index)
{
    $progress[2] = $index
}

function Set-ProgressBarTotal([int]$total)
{
    $progress[3] = $total
}

function Write-ProgressBar($Status)
{
    if ($Status) 
    {
        $progress[1] = $Status
    }
    $progress[2] += 1
    $progressindex = $progress[2]
    if ($progressindex -gt $progress[3])
    {
        $progressindex = $progress[3]
    }
    Write-Progress -activity $progress[0] -status $progress[1] -PercentComplete (($progressindex / $progress[3])  * 100)
    Write-Host "$($progress[1]) in process..."
}

function Get-ProgressBarIndex
{
    return $progress[2]
}

function Get-ProgressBarTotal
{
    return $progress[3]
}

<#
    # Example how to use progress
    cls
    For ($i=0; $i -lt 10; $i++)
    {
        Start-Sleep -Seconds 1
        Write-ProgressBar "Test $i"
    }

    Write-Host "Last Index is $(Get-ProgressBarIndex)"
#>
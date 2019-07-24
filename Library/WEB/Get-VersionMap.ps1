# KB article Map and composing urls based on existing pattern

# https://support.microsoft.com/en-us/help/4072483/released-cumulative-updates-for-microsoft-dynamics-nav-2018
# https://support.microsoft.com/en-us/help/3210255/released-cumulative-updates-for-microsoft-dynamics-nav-2017
# https://support.microsoft.com/en-us/help/3108728/released-cumulative-updates-for-microsoft-dynamics-nav-2016
# https://support.microsoft.com/en-us/help/3014609/released-cumulative-updates-for-microsoft-dynamics-nav-2015
# https://support.microsoft.com/en-us/help/2914930/released-cumulative-updates-for-microsoft-dynamics-nav-2013-r2
# https://support.microsoft.com/en-us/help/2842257/released-cumulative-updates-for-microsoft-dynamics-nav-2013     

. ".\Invoke-WebRequest.ps1"

function Get-VersionMap
{
    return @(
      @{ "VersionNo"="700";  "VersionName"="2013";    "KBArticle"="2842257"};
      @{ "VersionNo"="710";  "VersionName"="2013-r2"; "KBArticle"="2914930"};
      @{ "VersionNo"="800";  "VersionName"="2015";    "KBArticle"="3014609"};
      @{ "VersionNo"="900";  "VersionName"="2016";    "KBArticle"="3108728"};
      @{ "VersionNo"="1000"; "VersionName"="2017";    "KBArticle"="3210255"};
      @{ "VersionNo"="1100"; "VersionName"="2018";    "KBArticle"="4072483"};
    )
}

function Get-ArrayIndexOfVersionNo($array, $ver)
{
    $result = -1
    for ($i = 0; $i -lt $array.count; $i++)
    {        
        if ($array[$i].VersionNo -eq $ver)
        {
            $result = $i
        }
    }
    return $result
}

function Get-NAVLink($array, $ver)
{
    $index = Get-ArrayIndexOfVersionNo -array $array -ver $ver
    return "https://support.microsoft.com/en-us/help/$($array[$index].KBArticle)/released-cumulative-updates-for-microsoft-dynamics-nav-$($array[$index].VersionName)"
}

# Example
# $verMap = Get-VersionMap
# Write-Host (Get-NAVLink -array (Get-VersionMap) -ver "900")

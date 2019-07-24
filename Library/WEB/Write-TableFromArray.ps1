# Display hash array in more usefull layout
function Write-TableFromArray($array)
{
    $array.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize
}

# Example
#
# $array = @(@{ "VersionNo"="700";  "VersionName"="2013";    "KBArticle"="2842257"}; @{ "VersionNo"="710";  "VersionName"="2013-r2"; "KBArticle"="2914930"})
# Write-TableFromArray($array)
# Parse table from page
. ".\Invoke-WebRequest.ps1"

# From result we need to first extract JavaScript function that returns Json file.
function Get-WebContentPart($content, $kb)
{
    $SearchStart = "return { 'en-us/$kb' :"
    $SearchEnd = "}}"
    $part = $content.Substring($content.IndexOf($SearchStart)+$SearchStart.Length)
    $part = $part.Substring(1, $part.IndexOf($SearchEnd))
    $json = $part | ConvertFrom-Json
    return $json.details.body[1].content
}

function Get-WebContentArrayHeaderCell($content)
{
    $array = @();
    $html = New-Object -ComObject "HTMLFile"
    $html.IHTMLDocument2_write("<table>$content</table>")
    foreach($element in ($html.getElementsByTagName("th")))
    {
        $string = $element.innerText
        $string = $string -replace '\s',''
        $string = $string -replace '`n',''
        $string = $string -replace '`r',''
        $array += $string
    }
    return $array
}

function Get-WebContentArrayCell($content, $columns)
{
    $array = @{};
    $html = New-Object -ComObject "HTMLFile"
    $html.IHTMLDocument2_write("<table>$content</table>")
    $index = 0
    foreach($element in ($html.getElementsByTagName("td")))
    {
        $array.add($columns[$index], $element.innerText)
        $index += 1
    }
    return $array
}

function Get-WebContentArray($content)
{
    $array = New-Object System.Collections.ArrayList
    $html = New-Object -ComObject "HTMLFile"
    $html.IHTMLDocument2_write($content)
    foreach($element in ($html.getElementsByTagName("tr")))
    {
        if ($element.innerHtml.Substring(1, 2) -eq "TH")
        {
            $columns = Get-WebContentArrayHeaderCell -content $element.outerHtml
        }
        else
        {
            $array.add((Get-WebContentArrayCell -content $element.outerHtml -columns $columns))
        }
    }
    return $array
}

function Get-CumulativeUpdateMap($kb, $ver)
{
    $result = Get-WebContentArray -content (Get-WebContentPart -content (Invoke-WebRequest("https://support.microsoft.com/en-us/help/$kb/released-cumulative-updates-for-microsoft-dynamics-nav-$ver")) -kb $kb) 
    # In array we see additional array elements that are created due to some bug related to System.Collections.ArrayList when converted to Table
    # Simple resolution is to copy second half of the array
    $result = $result[($result.Length/2)..$result.Length]
    return  $result
}

function Get-NAVKBLink($kbarrayitem)
{
    # 'https://support.microsoft.com/en-us/help/4058601/cumulative-update-01-for-microsoft-dynamics-nav-2018-build-19846'
    $link = $kbarrayitem.Title
    $link = $link -replace '\s','-'
    $link = $link + "-build-" + $kbarrayitem.'BuildNo.'
    $link = 'https://support.microsoft.com/en-us/help/' + $kbarrayitem.KnowledgeBaseID + '/' + $link
    return $link.ToLower()
}

# Example
. ".\Write-TableFromArray.ps1"
. ".\Get-VersionMap.ps1"
Clear-Host
$verarray = Get-VersionMap
foreach($ver in $verarray)
{
    Write-Host "-------------------------"
    Write-Host $ver.VersionName
    $kbarray = Get-CumulativeUpdateMap -kb $ver.KBArticle -ver $ver.VersionName
    Write-TableFromArray($kbarray)
    Write-Host "Previous KB: $($kbarray[1].KnowledgeBaseID), New KB: $($kbarray[0].KnowledgeBaseID) released $($kbarray[0].Releasedate)" 
    Write-Host (Get-NAVKBLink($kbarray[0]))
}
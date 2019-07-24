function Get-DownloadLink($kbarticle)
{
    $result = Get-WebContentArray -content (Get-WebContentPart -content (Invoke-WebRequest("")) -kb $kb) 
    # In array we see additional array elements that are created due to some bug related to System.Collections.ArrayList when converted to Table
    # Simple resolution is to copy second half of the array
    $result = $result[($result.Length/2)..$result.Length]
    return  $result
}

function Get-DownloadLinkFromContent($content)
{
    $array = New-Object System.Collections.ArrayList
    $html = New-Object -ComObject "HTMLFile"
    $html.IHTMLDocument2_write($content)
    foreach($element in ($html.getElementsByTagName("a")))
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

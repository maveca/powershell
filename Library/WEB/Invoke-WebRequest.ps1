# This function is not supported anymore in ps natively. Here is simple GET reimplemented:
function Invoke-WebRequest($uri)
{
    $request = [System.Net.WebRequest]::Create($uri)
    $request.UseDefaultCredentials = $true
    $request.Method = "GET"
    [System.Net.WebResponse]$response = $request.GetResponse()
    $responsestream = $response.GetResponseStream()
    $stream = new-object System.IO.StreamReader $responsestream
    $result = $stream.ReadToEnd()
    $response.Close()
    return $result
}

# Example
# Write-Host (Invoke-WebRequest("https://support.microsoft.com/en-us/help/4072483/released-cumulative-updates-for-microsoft-dynamics-nav-2018"))

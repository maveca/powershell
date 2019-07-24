function Install-NAVWebService($webservers)
{
    # Install web server instances
    foreach ($webserver in $webservers)
    {
        New-NAVWebServerInstance -Server $webserver.Server -ServerInstance $webserver.ServerInstance -SiteDeploymentType $webserver.SiteDeploymentType -ClientServicesPort $webserver.ClientServicesPort -WebServerInstance $webserver.WebServerInstance -WebSitePort $webserver.WebSitePort
    }
}

function Uninstall-NAVWebService()
{
    # Remove Web Service Instances
    # Load web server applications into array
    $webservers = @()
    foreach ($ws in get-childitem IIS:\Sites)
    {
        $wa = Get-WebApplication -Site $ws.Name
        foreach ($a in $wa)
        {
            $webserver = Get-NAVWebServerInstance -WebServerInstance ($a.path).Substring(1)
            $webservers += $webserver
        }
    }
    # Delete web applications
    foreach ($webserver in $webservers)
    {
        Remove-NAVWebServerInstance -WebServerInstance $webserver.WebServerInstance -SiteDeploymentType SubSite
    }
    return $webservers
}

$wscs = Uninstall-NAVWebService
Install-NAVWebService -webservers $wscs
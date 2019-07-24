function Install-NAVWebService($webservers)
{
    # Install web server instances
    foreach ($webserver in $webservers)
    {
        New-NAVWebServerInstance -Server "navdev-lj-19" -ServerInstance $webserver -SiteDeploymentType SubSite -WebServerInstance $webserver
    }
}

function Uninstall-NAVWebService()
{
    # Remove Web Service Instances
    # Load web server applications into array

    $webservers = @("ADACTA_NAV_110_BLD", "ADACTA_NAV_110_DEV", "ADACTA_NAV_110_TST", "ADACTA_NAV_110_TESTABILITY", "NAV_NAV_110_W1")
    # Delete web applications
    foreach ($webserver in $webservers)
    {
        Remove-NAVWebServerInstance -WebServerInstance $webserver -SiteDeploymentType SubSite
    }
    return $webservers
}

# Example
# $wscs = Uninstall-NAVWebService
# Install-NAVWebService -webservers $wscs
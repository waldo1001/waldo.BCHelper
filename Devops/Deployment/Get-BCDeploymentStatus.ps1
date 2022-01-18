
function Get-BCDeploymentStatus {
    <#
    .Synopsis
        Gets the deployment status from apps through the Automation API
    .DESCRIPTION
        Gets the deployment status from apps through the Automation API
    #>
    [CmdletBinding(DefaultParameterSetName = "Credential")]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "OAuth")]
        $clientId,
        [Parameter(Mandatory = $true, ParameterSetName = "OAuth")]
        $clientSecret,
        [Parameter(Mandatory = $true, ParameterSetName = "OAuth")]
        [string] $tenantId,
        [Parameter(Mandatory = $true, ParameterSetName = "OAuth")]
        [string] $Environment,
        [Parameter(Mandatory = $true, ParameterSetName = "Credential")]
        [pscredential] $Credential,
        [Parameter(Mandatory = $false, ParameterSetName = "Credential")]
        [string] $Tenant = 'default',
        [Parameter(Mandatory = $false)]
        [string] $EnvironmentURL = "https://api.businesscentral.dynamics.com/v2.0"
    )

    if ($TenantId) {
        $EnvironmentURL += "/" + $TenantId
    }
    if ($Environment) {
        $EnvironmentURL += "/" + $Environment
    }

    $EnvironmentURL += "/api/microsoft/automation/beta"

    if ($psCmdLet.ParameterSetName -eq 'OAuth') {
        $bcauthContext = New-BcAuthContext `
            -clientID $clientID `
            -clientSecret $clientSecret `
            -tenantID $tenantId 

        $authHeaders = @{ "Authorization" = "Bearer $($bcauthcontext.AccessToken)" }
        
        Write-Host -ForegroundColor Green "Getting Companies with $EnvironmentURL/companies"
        $Companies = Invoke-RestMethod -Method Get `
            -Uri "$EnvironmentURL/companies" `
            -Headers $authHeaders `
            -UseBasicParsing
            
        
        $companyId = $Companies.value[0].id

        Write-Host -ForegroundColor Green -Object "Deployment Status at $EnvironmentURL/companies($companyId)/extensionDeploymentStatus :"
        $extensionDeploymentStatusResponse = Invoke-RestMethod -Method Get `
            -Uri "$EnvironmentURL/companies($companyId)/extensionDeploymentStatus" `
            -Headers $authHeaders `
            -UseBasicParsing
        
    }
    else {
        Write-Host -ForegroundColor Green "Getting Companies with $EnvironmentURL/companies" `
        
        $Companies = Invoke-RestMethod -Method Get `
            -Uri "$EnvironmentURL/companies?Tenant=$Tenant" `
            -Credential $Credential `
            -UseBasicParsing

        $companyId = $Companies.value[0].id

        Write-Host -ForegroundColor Green -Object "Deployment Status at $EnvironmentURL/companies($companyId)/extensionDeploymentStatus :"
        $extensionDeploymentStatusResponse = Invoke-RestMethod -Method Get `
            -Uri "$EnvironmentURL/companies($companyId)/extensionDeploymentStatus?Tenant=$Tenant" `
            -Credential $Credential `
            -UseBasicParsing
    }
            
    $extensionDeploymentStatusResponse.value | Select name, publisher, operationType, status, schedule, appVersion, startedOn | Sort startedOn -Descending
            
}

Get-BCDeploymentStatus -tenantId "d61c0367-b31d-4f6b-ab32-7fbb2e1c2772" -Environment 'LIVE' -clientId "6dd73082-49c8-45da-8b8c-03a93f14de97" -clientSecret "drD7Q~kQIQQ-vinQdURAwPCczaqq2RntRT4Vh"

$pwd = ConvertTo-SecureString 'Waldo1234'-AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ('waldo', $pwd)
Get-BCDeploymentStatus -Credential $Credential -EnvironmentURL "http://bccurrent:7048/bc"

$pwd = ConvertTo-SecureString '9;mE2nVn13'-AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ('wauteri@ifacto.be', $pwd)
Get-BCDeploymentStatus -credential $Credential -EnvironmentURL "https://05b6969c9c.infra.ifacto.be/BC"
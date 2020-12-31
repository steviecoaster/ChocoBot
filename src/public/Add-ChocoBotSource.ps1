function Add-ChocoBotSource {
    <#
    .SYNOPSIS
    Adds a Chocolatey source to target computer(s).
    
    .DESCRIPTION
    Adds a Chocolatey source to target computer(s).
    
    .PARAMETER FriendlyName
    This is the human name of the source. E.g.: chocolatey
    
    .PARAMETER Source
    This is the path to the source. E.g.: https://chocolatey.org/api/v2
    
    .PARAMETER Computername
    The computer(s) to add a source
    
    .PARAMETER AllowSelfService
    Enables Self Service mode for the source
    
    .PARAMETER AdminOnly
    Allows only members of the local Administrators group to use the source
    
    .PARAMETER Priority
    Set the priority of the source for retrieving packages
    
    .PARAMETER Credential
    If authentication is required for the source, provide those credentials
    
    .PARAMETER PFXCertificate
    If a certificate is required for the source, add the path to the PFX certificate
    
    .PARAMETER CertificatePassword
    If the PFX certificate has a password, enter it here
    
    .PARAMETER BypassProxy
    Instruct the source to bypass any system proxy configuration that may be applied
    
    .EXAMPLE
    Minimal source additon example
    Add-ChocoSource -FriendlyName MyRepo -Source https://myrepository.com:8443/repository/MyRepo/ -Computername Finance01

    .EXAMPLE
    Add an authenticated source

    Add-ChocoBotSource -FriendlyName MyRepo -Source https://myrepository.com:8443/repository/MyRepo/ -Credential $credential -Computername Finance01

    .EXAMPLE
    Add a self-service enabled source

    Add-ChocoBotSource -FriendlyName MyRepo -Source https://myrepository.com:8443/repository/MyRepo/ -AllowSelfService -Computername Finance01
    #>
    [PoshBot.BotCommand(CommandName = 'addsource')]
    [cmdletBinding(HelpUri="https://github.com/steviecoaster/ChocoBot/blob/main/Help/Add-ChocoBotSource.md")]
    param(
        [Parameter(Mandatory)]
        [String]
        $FriendlyName,
        
        [Parameter(Mandatory)]
        [String]
        $Source,

        [Parameter()]
        [String[]]
        [Alias('Target','Computer')]
        $Computername,

        [Parameter()]
        [Switch]
        $AllowSelfService,

        [Parameter()]
        [Switch]
        $AdminOnly,

        [Parameter()]
        [ValidateRange(0,100)]
        [Int]
        $Priority,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [ValidateScript({ Test-Path $_})]
        [String]
        $PFXCertificate,
        
        [Parameter()]
        [String]
        $CertificatePassword,

        [Parameter()]
        [Switch]
        $BypassProxy
    )

    process {

        $chocoArgs = [System.Collections.Generic.List[string]]::new()

        #Add the base arguments, then Add the remainder from provided parameter values
        $chocoArgs.Add('source')
        $chocoArgs.Add('add')
        

        foreach($BoundParam in $PSBoundParameters.GetEnumerator()){
            $parameter = $null
            $value = $null

            switch($BoundParam.Key){
                'FriendlyName' {
                    $parameter = '--name'
                    $value = $BoundParam.Value
                    $chocoArgs.Add("$parameter='$value'")

                    
                }
                'Source' {
                    $parameter = '--source'
                    $value = $BoundParam.Value
                    $chocoArgs.Add("$parameter='$value'")

                }
                'AllowSelfService' {
                    $chocoArgs.Add('--allow-self-service')
                }
                'AdminOnly' {
                    $chocoArgs.Add('--admin-only')
                }
                'Priority' {
                    $parameter = '--priority'
                    $value = $BoundParam.Value
                    $chocoArgs.Add("$parameter='$value'")

                }
                'Credential' {
                    $chocoArgs.Add('--user="$($Credential.UserName)"')
                    $chocoArgs.Add('--password="$($Credential.GetNetworkCredential().Password)"')
                }
                'PFXCertificate' {
                    $parameter = '--cert'
                    $value = $BoundParam.Value
                    $chocoArgs.Add("$parameter='$value'")

                }
                'CertificatePassword' {
                    $parameter = '--certpassword'
                    $value = $BoundParam.Value
                    $chocoArgs.Add("$parameter='$value'")

                }
                'BypassProxy' {
                    $chocoArgs.Add('--bypass-proxy')
                }
            }
    
        }
        
        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Chocolatey Source Added"
            Text  = [pscustomobject]@{
                Name = $FriendlyName
                Source = $Source
                SelfService = $AllowSelfService
                AdminOnly = $AdminOnly
                BypassProxy = $BypassProxy
            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams

    }
}
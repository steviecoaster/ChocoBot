function Add-ChocoBotSource {

    [PoshBot.BotCommand(CommandName = 'addsource')]
    [cmdletBinding()]
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
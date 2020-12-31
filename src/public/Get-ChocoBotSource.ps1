function Get-ChocoBotSource {
    <#
    .SYNOPSIS
    Retrieves all configured Chococlatey sources.
    
    .DESCRIPTION
    Retrieves the details all configured Chocolatey sources on provided computer name(s).
    
    .PARAMETER Computername
    The computer(s) to query
    
    .EXAMPLE
    Get-ChocoBotSource -ComputerName PC1,PC2
    #>

    [PoshBot.BotCommand(CommandName = 'getsource')]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String[]]
        $Computername
    )

    process {

        $job = Invoke-Command -ComputerName $Computername -ScriptBlock {
             
           choco source list -r | ConvertFrom-Csv -Delimiter '|' -Header FriendlyName,Source,Disabled,Username,Password,Priority,BypassProxy,SelfServiceEnabled,AdminOnly
           
        } -AsJob

        $job | Wait-Job | Receive-Job


    }
}
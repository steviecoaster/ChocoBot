function Uninstall-ChocoBotPackage {
    <#
    .SYNOPSIS
    Uninstalls a list of Chocolatey Packages on the target machine(s).
    
    .DESCRIPTION
    This function uses PSRemoting to Uninstall the provided list of Chocolatey packages on the target machine(s) specified in the chat message.
    
    .PARAMETER Package
    The Chocolatey Package(s) to Uninstall.
    
    .PARAMETER Computername
    The target computer(s) on which to perform the Uninstallation of the Chocolatey Package(s).
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    [PoshBot.BotCommand(CommandName = 'Uninstall')]
    [CmdletBinding(HelpUri="https://github.com/steviecoaster/ChocoBot/blob/main/Help/Uninstall-ChocoBotPackage.md")]
    Param(
        [Parameter(Mandatory)]
        [String[]]
        $Package,

        [Parameter(Mandatory)]
        [String[]]
        [Alias('Target', 'Computer')]
        $Computername,

        [Parameter()]
        [Switch]
        $Force
    )

    process {

        $chocoArgs = [System.Collections.Generic.List[string]]::new()
        
        @('uninstall', $Package, '-y') | ForEach-Object { $chocoArgs.Add($_) }

        if ($Source) {
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs
        
        $cardParams = @{
            Title = "Package Uninstallation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
    }
}
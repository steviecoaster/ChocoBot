function Upgrade-ChocoBotPackage {
    <#
    .SYNOPSIS
    Upgrades a list of Chocolatey Packages on the target machine(s).
    
    .DESCRIPTION
    This function uses PSRemoting to Upgrade the provided list of Chocolatey packages on the target machine(s) specified in the chat message.
    
    .PARAMETER Package
    The Chocolatey Package(s) to Upgrade.
    
    .PARAMETER Computername
    The target computer(s) on which to perform the Upgrade of the Chocolatey Package(s).
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the upgrade of the package to occur, even if it is already Upgradeed
    
    .EXAMPLE
    Upgrade all Chocolatey packages on target computer(s)

    UpgradeChocoBotPackage -Computername Finance01

    .EXAMPLE
    Upgrade only the vlc package

    Upgrade-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Upgrade multiple packages on multiple machines
    
    Upgrade-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    [PoshBot.BotCommand(CommandName = 'upgrade')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Upgrade-ChocoBotPackage.md")]
    Param(
        [Parameter()]
        [String[]]
        $Package = 'all',

        [Parameter(Mandatory)]
        [String[]]
        [Alias('Target', 'Computer')]
        $Computername,

        [Parameter()]
        [String]
        $Source,

        [Parameter()]
        [Switch]
        $Force
    )

    process {

        $chocoArgs = [System.Collections.Generic.List[string]]::new()
        
        @('upgrade', $Package, '-y', '--no-progress') | ForEach-Object { $chocoArgs.Add($_) }

        if ($Source) {
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Upgradea Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
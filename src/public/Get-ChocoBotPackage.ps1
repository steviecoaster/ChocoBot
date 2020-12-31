function Get-ChocoBotPackage {
<#
.SYNOPSIS
Retrieves packages available on a source per Computername

.DESCRIPTION
Retrieves packages available on a source per Computername

.PARAMETER Source
The source to query

.PARAMETER Computername
The computer name(s) to run against

.PARAMETER Package
Optionally the specific package to query

.EXAMPLE
Get-ChocoBotPackage -Source MyRepo -Computername Finance01

.EXAMPLE
Get-ChocoBotPackage -Source https://myserver:8443/repository/MyRepo/ -Computername Finance01

.EXAMPLE
Get-ChocoBotPackage -Source MyRepo -Computername Finance01 -Package lob-app
#>
    [PoshBot.BotCommand(CommandName = 'listpackages')]
    [CmdletBinding(HelpUri="https://github.com/steviecoaster/ChocoBot/blob/main/Help/Get-ChocoBotPackage.md")]
    Param(
        [Parameter(Mandatory)]
        [String]
        $Source,

        [Parameter(Mandatory)]
        [String[]]
        [Alias('Computer', 'Target')]
        $Computername,

        [Parameter()]
        [String]
        $Package
    )

    process {

        if (-not $Package) {
            $job = Invoke-Command -ComputerName $Computername -ScriptBlock {
             
                choco list -s $using:Source -r | ConvertFrom-Csv -Delimiter '|' -Header PackageName, PackageVersion
            
            } -AsJob
 
            $data = $job | Wait-Job | Receive-Job

            $cardParams = @{
                Title = 'Package Results'
                Text  = $data | Select-Object PackageName,PackageVersion,@{N='Target';E={$_.PSComputername}} | Out-String
                Type  = 'Normal'
            }

            New-PoshbotCardResponse @cardParams
        } else {
            $job = Invoke-Command -ComputerName $Computername -ScriptBlock {
             
                choco list $using:Package -s $using:Source -r | ConvertFrom-Csv -Delimiter '|' -Header PackageName, PackageVersion
            
            } -AsJob
 
            $data = $job | Wait-Job | Receive-Job

            $cardParams = @{
                Title = 'Package Results'
                Text  = $data | Select-Object PackageName,PackageVersion,@{N='Target';E={$_.PSComputername}} | Out-String
                Type  = 'Normal'
            }

            New-PoshbotCardResponse @cardParams

        }
    }
}
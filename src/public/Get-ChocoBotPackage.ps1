function Get-ChocoBotPackage {
    <#
.SYNOPSIS
Retrieves packages available on a source per Computername

.DESCRIPTION
Retrieves packages available on a source per Computername

.PARAMETER Source
The source to query

.PARAMETER LocalOnly
Return installed Chocolatey Package information

.PARAMETER Computername
The computer name(s) to run against

.PARAMETER Package
Optionally the specific package to query

.EXAMPLE
Returns all installed Chocolatey packages on Finance01

Get-ChocoBotPackage -LocalOnly -Computername Finance01

.EXAMPLE
Returns all packages available on the MyRepo source for Finance01

Get-ChocoBotPackage -Source MyRepo -Computername Finance01

.EXAMPLE
Get-ChocoBotPackage -Source https://myserver:8443/repository/MyRepo/ -Computername Finance01

.EXAMPLE
Get-ChocoBotPackage -Source MyRepo -Computername Finance01 -Package lob-app
#>
    [PoshBot.BotCommand(CommandName = 'listpackages')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Get-ChocoBotPackage.md")]
    Param(
        [Parameter()]
        [String]
        $Source,

        [Parameter()]
        [Alias('Installed')]
        [Switch]
        $LocalOnly,

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
            if ($LocalOnly) {
                $job = Invoke-Command -ComputerName $Computername -ScriptBlock {
             
                    choco list -lo -r | ConvertFrom-Csv -Delimiter '|' -Header PackageName, PackageVersion
                
                } -AsJob
     
                $data = $job | Wait-Job | Receive-Job
    
                $cardParams = @{
                    Title = 'Package Results'
                    Text  = $data | Select-Object PackageName, PackageVersion, @{N = 'Target'; E = { $_.PSComputername } } | Out-String
                    Type  = 'Normal'
                }
    
                New-PoshbotCardResponse @cardParams
    
            }

            if ($Source) {
                $job = Invoke-Command -ComputerName $Computername -ScriptBlock {
             
                    choco list -s $using:Source -r | ConvertFrom-Csv -Delimiter '|' -Header PackageName, PackageVersion
                
                } -AsJob
     
                $data = $job | Wait-Job | Receive-Job
    
                $cardParams = @{
                    Title = 'Package Results'
                    Text  = $data | Select-Object PackageName, PackageVersion, @{N = 'Target'; E = { $_.PSComputername } } | Out-String
                    Type  = 'Normal'
                }
    
                New-PoshbotCardResponse @cardParams
                
            }
        }
        else {

            if($LocalOnly){
                $job = Invoke-Command -ComputerName $Computername -ScriptBlock {
             
                    choco list $using:Package -lo -r | ConvertFrom-Csv -Delimiter '|' -Header PackageName, PackageVersion
            
                } -AsJob
 
                $data = $job | Wait-Job | Receive-Job

                $cardParams = @{
                    Title = 'Package Results'
                    Text  = $data | Select-Object PackageName, PackageVersion, @{N = 'Target'; E = { $_.PSComputername } } | Out-String
                    Type  = 'Normal'
                }

                New-PoshbotCardResponse @cardParams
            }

            if ($Source) {
                $job = Invoke-Command -ComputerName $Computername -ScriptBlock {
             
                    choco list $using:Package -s $using:Source -r | ConvertFrom-Csv -Delimiter '|' -Header PackageName, PackageVersion
            
                } -AsJob
 
                $data = $job | Wait-Job | Receive-Job

                $cardParams = @{
                    Title = 'Package Results'
                    Text  = $data | Select-Object PackageName, PackageVersion, @{N = 'Target'; E = { $_.PSComputername } } | Out-String
                    Type  = 'Normal'
                }

                New-PoshbotCardResponse @cardParams
        
            }

        }

    }

}
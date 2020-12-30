function Install-ChocoBotPackage {
    <#
    .SYNOPSIS
    Installs a list of Chocolatey Packages on the target machine(s).
    
    .DESCRIPTION
    This function uses PSRemoting to install the provided list of Chocolatey packages on the target machine(s) specified in the chat message.
    
    .PARAMETER Package
    The Chocolatey Package(s) to install.
    
    .PARAMETER Computername
    The target computer(s) on which to perform the installation of the Chocolatey Package(s).
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the installation of the package to occur, even if it is already installed
    
    .EXAMPLE
    Install-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Install-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    [PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri="https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
    Param(
        [Parameter(Mandatory)]
        [String[]]
        $Package,

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
        
        @('install', $Package, '-y', '--no-progress') | ForEach-Object { $chocoArgs.Add($_) }

        if ($Source) {
            $chocoArgs += '--source="$Source"'
        }

        if ($Force) {
            $chocoArgs += '--force'
        }
        
        Invoke-Command -ComputerName $Computername -ScriptBlock {
            
            $arg = $using:ChocoArgs
            
            #Build Complex process
            $statements = "$($arg -join ' ')"
            $process = New-Object System.Diagnostics.Process
            $process.EnableRaisingEvents = $true

            #Register-ObjectEvent -InputObject $process -SourceIdentifier "LogOUtput"
        
            #StartInfo properties
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = 'C:\ProgramData\chocolatey\bin\choco.exe'
            $psi.Arguments = "$statements"
            $psi.CreateNoWindow = $true
            $psi.UseShellExecute = $false
            $psi.RedirectStandardOutput = $true

            #Kick off our process
            $process.StartInfo = $psi
            $null = $process.Start()
            $process.WaitForExit()
            $null = $process.Dispose()
        }
    }
}
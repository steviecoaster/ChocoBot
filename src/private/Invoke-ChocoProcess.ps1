function Invoke-ChocoProcess {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [System.Collections.Generic.List[string]]
        $ChocoArgs

    )

    process {

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
function Add-ChocoBotSource {
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

    }
}
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
        
        if($LASTEXITCODE -eq 0){
            [pscustomObject]@{
                Result = "Success"
                Package = $Package
                Targets = $Computername
            }
        }

        else {
            [pscustomobject]@{
                Result = "Failed"
                Package = $Package
                Targets = $Computername
            }
        }
    }
}
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
function Add-ChocoBotSource {
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
    }
}
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
function Add-ChocoBotSource {
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
function Get-ChocoBotPackage {
    [CmdletBinding()]
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
                Text  = $data | Out-String
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
                Text  = $data | Out-String
                Type  = 'Normal'
            }

            New-PoshbotCardResponse @cardParams

        }
    }
}
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
function Add-ChocoBotSource {
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
function Get-ChocoBotPackage {
    [CmdletBinding()]
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
                Text  = $data | Out-String
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
                Text  = $data | Out-String
                Type  = 'Normal'
            }

            New-PoshbotCardResponse @cardParams

        }
    }
}
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
function Add-ChocoBotSource {
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
function Get-ChocoBotPackage {
    [CmdletBinding()]
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
                Text  = $data | Out-String
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
                Text  = $data | Out-String
                Type  = 'Normal'
            }

            New-PoshbotCardResponse @cardParams

        }
    }
}
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
function Add-ChocoBotSource {
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
function Get-ChocoBotPackage {
    [CmdletBinding()]
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
                Text  = $data | Out-String
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
                Text  = $data | Out-String
                Type  = 'Normal'
            }

            New-PoshbotCardResponse @cardParams

        }
    }
}
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
function Add-ChocoBotSource {
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
function Get-ChocoBotPackage {
    [CmdletBinding()]
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
                Text  = $data | Select-Object PackageName,PackageVersion | Out-String
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
                Text  = $data | Out-String
                Type  = 'Normal'
            }

            New-PoshbotCardResponse @cardParams

        }
    }
}
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
function Add-ChocoBotSource {
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
function Get-ChocoBotPackage {
    [CmdletBinding()]
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
                Text  = $data | Select-Object PackageName,PackageVersion | Out-String
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
                Text  = $data | Select-Object PackageName,PackageVersion | Out-String
                Type  = 'Normal'
            }

            New-PoshbotCardResponse @cardParams

        }
    }
}
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
function Add-ChocoBotSource {
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
function Get-ChocoBotPackage {
    [CmdletBinding()]
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
                Text  = $data | Select-Object PackageName,PackageVersion | Out-String
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
function Add-ChocoBotSource {
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
    [CmdletBinding()]
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
function Add-ChocoBotSource {
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
    [CmdletBinding()]
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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
function Add-ChocoBotSource {
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
    [CmdletBinding()]
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

    #Wire PoshBot CommandNamehere
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
    #[PoshBot.BotCommand(CommandName = 'install')]
    [CmdletBinding(HelpUri = "https://github.com/steviecoaster/ChocoBot/blob/main/Help/Install-ChocoBotPackage.md")]
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
            $chocoArgs.Add("--source='$Source'")
        }

        if ($Force) {
            $chocoArgs.Add('--force')
        }

        Invoke-ChocoProcess -ChocoArgs $chocoArgs

        $cardParams = @{
            Title = "Package Installation Complete"
            Text  = [pscustomobject]@{
                Package = $Package
                Targets = $Computername

            } | Format-List -Property * | Out-String
            Type  = 'Normal'
        }

        New-PoshbotCardResponse @cardParams
        
    }
    
}
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
    
    .PARAMETER Source
    If specified, will attempt to locate Chocolatey Packages from this location explicitly.
    
    .PARAMETER Force
    Will force the Uninstallation of the package to occur, even if it is already Uninstalled
    
    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc -Computername Finance01

    .EXAMPLE
    Uninstall-ChocoBotPackage -Package vlc,googlechrome,vscode -Computername ((Get-ADComputer -SearchBase "OU=Finance,OU=Chicago","DC=fabrikam",DC=com".Name)
    #>
    #[PoshBot.BotCommand(CommandName = 'Uninstall')]
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
        [String]
        $Source,

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

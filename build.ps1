[CmdletBinding()]
Param(
    [Parameter(ParameterSetName = "build")]
    [Switch]
    $Build,

    [Parameter(ParameterSetName = "test")]
    [Switch]
    $Test,

    [Parameter(ParameterSetName = "deploy")]
    [Switch]
    $Deploy
)

process {
    switch ($PSCmdlet.ParameterSetName) {
        'Build' {

            if(Test-Path $PSScriptRoot\src\Choco.Poshbot.psm1){
                Remove-Item $PSScriptRoot\src\Choco.Poshbot.psm1 -Recurse -Force
            }

            Get-ChildItem $PSScriptRoot\src\public -Recurse -Filter *.ps1 | 
            Foreach-Object { Get-Content $_.FullName  | Add-Content $PSScriptRoot\src\ChocoBot.psm1 }

            Get-ChildItem $PSScriptRoot\src\private\ -Recurse -Filter *.ps1 |
            Foreach-Object { Get-Content $_.Fullname | Add-Content $PSScriptRoot\src\ChocoBot.psm1 }
        }

        'Test' {}
        'Deploy' {

            if(-not (Test-Path $PSScriptRoot\ChocoBot)){
                $null = New-Item $PSScriptRoot\ChocoBot -ItemType Directory
            } else {
                Remove-Item $PSScriptRoot\Chocobot\ -Recurse -Force
                $null = New-Item $PSScriptRoot\ChocoBot -ItemType Directory
            }

                Copy-Item $PSScriptRoot\src\ChocoBot* $PSScriptRoot\ChocoBot -Force
        }
    }
}

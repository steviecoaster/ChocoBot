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
            Get-ChildItem $PSScriptRoot\src\public\ -Recurse -Filter *.ps1 | 
            Foreach-Object { Get-Content $_.FullName  | Add-Content $PSScriptRoot\src\Choco.Poshbot.psm1 }
        }

        'Test' {}
        'Deploy' {}
    }
}

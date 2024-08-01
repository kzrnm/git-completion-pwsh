function Resolve-GitAlias {
    [CmdletBinding(DefaultParameterSetName = 'Simple')]
    param (
        [Parameter(Mandatory, Position = 0)][string] $Command,
        [Parameter(Mandatory, ParameterSetName = 'ActualCommand', HelpMessage = 'Resolve command recursively and return command name.')][switch] $ActualCommand
    )

    $resolved = (gitGetAlias $Command)
    switch ($PSCmdlet.ParameterSetName) {
        'Simple' {
            $resolved 
        }
        'ActualCommand' {
            if ($Command -like "!*") {
                return $null
            }

            $aliasValue = ([string[]](Invoke-Expression "echo $resolved -- --")) -NotLike "-*"
            $AliasCommand = $aliasValue[0]
            if ($AliasCommand) {
                Resolve-GitAlias $AliasCommand -ActualCommand
            }
            else {
                $Command
            }
        }
        Default { throw 'Invalid ParameterSetName' }
    }
}
Register-ArgumentCompleter -CommandName Resolve-GitAlias -ParameterName Command -ScriptBlock {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    gitListAliases | ForEach-Object {
        if ($_.Name.StartsWith($wordToComplete)) {
            [System.Management.Automation.CompletionResult]::new(
                $_.Name,
                $_.Name,
                'Text',
                $_.Value
            )
        }
    }
}
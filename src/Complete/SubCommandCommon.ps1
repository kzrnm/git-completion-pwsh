function Complete-GitSubCommandCommon {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $Current = $Context.CurrentWord()
    $Command = $Context.command

    [string] $Subcommand = $Context.Subcommand()

    if ($Subcommand -and ($Subcommand -like '*[:/\]*')) {
        if ($Current -eq '-') {
            $result = Get-GitShortOptions $Command $Subcommand
            if ($result) {
                return $result
            }
            Get-GitShortOptions $Command
            return
        }
        elseif ($Current.StartsWith('--')) {
            $result = gitCompleteResolveBuiltins $Command $Subcommand -Current $Current
            if ($result) {
                return $result
            }
    
            gitCompleteResolveBuiltins $Command -Current $Current
            return
        }
    }
    else {
        if ($Current -eq '-') {
            Get-GitShortOptions $Command
            return
        }
        elseif ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Command -Current $Current
            return
        }
    }
}
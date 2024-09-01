using namespace System.Management.Automation;

function Complete-GitSubCommand-describe {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if ($Current -eq '-') {
        return Get-GitShortOptions $Context.command
    }

    if ($Current.StartsWith('--')) {
        gitCompleteResolveBuiltins $Context.command -Current $Current
        return
    }

    gitCompleteRefs $Context.CurrentWord()
}
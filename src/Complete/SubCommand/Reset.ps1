using namespace System.Management.Automation;

function Complete-GitSubCommand-reset {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    if ($Context.HasDoubledash()) { return }

    $shortOpts = Get-GitShortOptions $Context.command -Current $Current
    if ($shortOpts) { return $shortOpts }

    if ($Current.StartsWith('--')) {
        gitCompleteResolveBuiltins $Context.command -Current $Current
        return
    }
    gitCompleteRefs $Context.CurrentWord()
}
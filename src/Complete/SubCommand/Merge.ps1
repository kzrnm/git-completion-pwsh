using namespace System.Management.Automation;

function Complete-GitSubCommand-merge {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if (!$Context.HasDoubledash()) { 
        $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
        if ($shortOpts) { return $shortOpts }

        $result = gitCompleteStrategy -Current $Current -Prev $Context.PreviousWord()
        if ($null -ne $result) { return $result }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
    }
    gitCompleteRefs $Context.CurrentWord()
}
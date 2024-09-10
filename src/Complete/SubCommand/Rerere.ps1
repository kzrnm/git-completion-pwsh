using namespace System.Management.Automation;

function Complete-GitSubCommand-rerere {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.command -Current $Current
        if ($shortOpts) { return $shortOpts }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.command -Current $Current
            return
        }

        if (!$Context.Subcommand()) {
            'clear', 'forget', 'diff', 'remaining', 'status', 'gc' | completeList -Current $Current
        }
    }
}
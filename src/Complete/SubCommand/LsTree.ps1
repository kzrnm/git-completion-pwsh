using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-ls-tree {
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

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
    }

    $skipOptions = [HashSet[string]]::new()
    foreach ($opt in (gitResolveBuiltins $Context.Command -All)) {
        if ($opt.EndsWith('=')) {
            $skipOptions.Add($opt) | Out-Null
        }
    }
    for ($i = $Context.CommandIndex + 1; $i -lt $Context.CurrentIndex; $i++) {
        $w = $Context.Words[$i]
        if ($skipOptions.Contains($w)) {
            $i++
        }
        elseif (!$w.StartsWith('-')) {
            return
        }
    }
    gitCompleteFile $Current
}

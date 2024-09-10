using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-clean {
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

    $skipOptions = [System.Collections.Generic.List[string]]::new()
    foreach ($opt in (gitResolveBuiltins $Context.Command -All)) {
        if ($opt.EndsWith('=')) {
            $skipOptions.Add($opt)
        }
    }

    $completeOpt = [IndexFilesOptions]::Untracked
    $UsedPaths = [System.Collections.Generic.List[string]]::new($Context.Words.Length)
    for ($i = $Context.CommandIndex + 1; $i -lt $Context.Words.Length; $i++) {
        if ($i -eq $Context.CurrentIndex) { continue }
        $w = $Context.Words[$i]
        if ($skipOptions.Contains($w)) { $i++ }
        elseif ($w -cmatch '^-[^-]*X$') {
            $completeOpt = [IndexFilesOptions]::Ignored
        }
        elseif (!$w.StartsWith('-') -or ($i -gt $Context.DoubledashIndex)) {
            $UsedPaths.Add($w)
        }
    }

    gitCompleteIndexFile -Current $Current -Options $completeOpt -Exclude $UsedPaths -LeadingDash:($Context.HasDoubledash())
}
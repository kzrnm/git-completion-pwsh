# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-mv {
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
    $UsedPaths = [List[string]]::new($Context.Words.Length)
    for ($i = $Context.CommandIndex + 1; $i -lt $Context.Words.Length; $i++) {
        if ($i -eq $Context.CurrentIndex) { continue }
        $w = $Context.Words[$i]
        if ($skipOptions.Contains($w)) { $i++ }
        elseif (!$w.StartsWith('-') -or ($i -gt $Context.DoubledashIndex)) {
            $UsedPaths.Add($w)
        }
    }

    $completeOpt = if ($UsedPaths.Count -gt 0) {
        [IndexFilesOptions]::CachedAndUntracked
    }
    else {
        [IndexFilesOptions]::Cached
    }
    gitCompleteIndexFile -Current $Current -Options $completeOpt -Exclude $UsedPaths -LeadingDash:($Context.HasDoubledash())
}

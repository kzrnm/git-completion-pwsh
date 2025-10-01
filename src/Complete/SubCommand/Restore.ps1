# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-restore {
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

        $prevCandidates = switch -CaseSensitive ($Context.PreviousWord()) {
            { $_ -cmatch '^-([^-]*s|-source)$' } {
                gitCompleteRefs -Current $Current
                return
            }
            '--conflict' { $gitConflictSolver }
        }

        if ($prevCandidates) {
            $prevCandidates | completeList -Current $Current -ResultType ParameterValue
            return
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive ($key) {
                '--source' {
                    gitCompleteRefs -Current $value -Prefix "$key="
                    return
                }
                '--conflict' { $gitConflictSolver }
            }

            if ($candidates) {
                $candidates | completeList -Current $Current -Prefix "$key=" -ResultType ParameterValue -RemovePrefix
                return
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
    }

    $completeOpt = [IndexFilesOptions]::Modified
    if (gitPseudorefExists HEAD) {
        $skipOptions = [HashSet[string]]::new()
        foreach ($opt in (gitResolveBuiltins $Context.Command -All)) {
            if ($opt.EndsWith('=')) {
                $skipOptions.Add($opt) > $null
            }
        }
        $UsedPaths = [List[string]]::new($Context.Words.Length)
        for ($i = $Context.CommandIndex + 1; $i -lt $Context.Words.Length; $i++) {
            if ($i -eq $Context.CurrentIndex) { continue }
            $w = $Context.Words[$i]
            if ($w -ceq '--staged') {
                $completeOpt = [IndexFilesOptions]::Staged
            }
            elseif ($skipOptions.Contains($w)) { $i++ }
            elseif (!$w.StartsWith('-') -or ($i -gt $Context.DoubledashIndex)) {
                $UsedPaths.Add($w)
            }
        }

        gitCompleteIndexFile -Current $Current -Options $completeOpt -Exclude $UsedPaths -LeadingDash:($Context.HasDoubledash())
    }
}
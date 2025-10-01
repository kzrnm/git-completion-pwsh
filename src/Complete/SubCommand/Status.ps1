# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-status {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    if (!$Context.HasDoubledash()) {
        if ($Current -cmatch '^(-[^-]*u)(.*)') {
            $prefix = $Matches[1]
            $value = $Matches[2]
            $script:gitUntrackedFileModes | completeList -Current $value -Prefix "$prefix" -ResultType ParameterValue
            return
        }

        $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
        if ($shortOpts) { return $shortOpts }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive ($key) {
                '--ignore-submodules' { 'none', 'untracked', 'dirty', 'all' }
                '--ignored' { 'traditional', 'matching', 'no' }
                '--untracked-files' { $script:gitUntrackedFileModes }
                '--column' { 'always', 'never', 'auto', 'column', 'row', 'plain', 'dense', 'nodense' }
            }

            if ($candidates) {
                $candidates | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
                return
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
    }

    $skipOptions = [HashSet[string]]::new()
    foreach ($opt in (gitResolveBuiltins $Context.Command -All)) {
        if ($opt.EndsWith('=')) {
            $skipOptions.Add($opt) > $null
        }
    }
    $untrackedState = $null
    $ignored = $false
    $UsedPaths = [List[string]]::new($Context.Words.Length)
    for ($i = $Context.CommandIndex + 1; $i -lt $Context.Words.Length; $i++) {
        if ($i -eq $Context.CurrentIndex) { continue }
        $w = $Context.Words[$i]
        if ($w -ceq '--ignored') {
            $ignored = $true
        }
        elseif ($w -cmatch '^(-[^-]*u)(.*)') {
            $untrackedState = $Matches[2]
        }
        elseif ($w -cmatch '--untracked-files=(.*)') {
            $untrackedState = $Matches[1]
        }
        elseif ($skipOptions.Contains($w)) { $i++ }
        elseif (!$w.StartsWith('-') -or ($i -gt $Context.DoubledashIndex)) {
            $UsedPaths.Add($w)
        }
    }

    if ($null -eq $untrackedState) {
        $untrackedState = __git config get 'status.showUntrackedFiles'
    }

    $completeOpt = if ($untrackedState -ceq 'no') {
        [IndexFilesOptions]::None
    }
    elseif ($ignored) {
        [IndexFilesOptions]::AllWithIgnored
    }
    else {
        [IndexFilesOptions]::All
    }
    gitCompleteIndexFile -Current $Current -Options $completeOpt -Exclude $UsedPaths -LeadingDash:($Context.HasDoubledash())
}

# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-history {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    [string] $subcommand = $Context.SubcommandWithoutGlobalOption()
    $subcommands = gitResolveBuiltins $Context.Command
    
    if (!$subcommand) {
        if (!$Context.HasDoubledash()) {
            if ($Current -eq '-') {
                $script:__helpCompletion
            }
            else {
                $subcommands | gitcomp -Current $Current -DescriptionBuilder { 
                    switch ($_) {
                        'drop' { 'Remove the specified commit from the history' }
                        'fixup' { 'Apply the currently staged changes to the specified commit' }
                        'reword' { 'Rewrite the commit message of the specified commit' }
                        'split' { 'Interactively split up <commit> into two commits by choosing hunks introduced by it that will be moved into the new split-out commit' }
                    }
                }
            }
        }
        return
    }

    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command $subcommand -Current $Current
        if ($shortOpts) { return $shortOpts }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive ($key) {
                '--empty' {
                    if ($subcommand -in @('drop', 'fixup')) {
                        @{ListItemText = 'drop'; Tooltip = '(default) empty commits are removed from the rewritten history'; },
                        @{ListItemText = 'keep'; Tooltip = 'empty commits are retained in the rewritten history as-is'; },
                        @{ListItemText = 'abort'; Tooltip = 'the command stops with an error if any commit would become empty'; }
                    }
                }
                '--update-refs' {
                    @{ListItemText = 'branches'; Tooltip = '(default) all local branches that point to commits which are descendants of the original commit will be rewritten'; },
                    @{ListItemText = 'head'; Tooltip = 'only the current HEAD reference will be rewritten'; }
                }
            }

            if ($candidates) {
                $candidates | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
                return
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command $subcommand -Current $Current
            return
        }
    }

    # __git_history_has_revision
    $revisionIndex = -1
    for ($i = $Context.CommandIndex + 2; $i -lt $Context.CurrentIndex; $i++) {
        if (!$Context.Words[$i].StartsWith('-')) {
            $revisionIndex = $i
            break
        }
    }

    if ($revisionIndex -lt 0) {
        gitCompleteRefs $Context.CurrentWord()
        return
    }

    if ($subcommand -eq 'split') {
        $skipOptions = [HashSet[string]]::new()
        foreach ($opt in (gitResolveBuiltins $Context.Command -All)) {
            if ($opt.EndsWith('=')) {
                $skipOptions.Add($opt) > $null
            }
        }
        $UsedPaths = [List[string]]::new($Context.Words.Length)
        for ($i = $revisionIndex + 1; $i -lt $Context.Words.Length; $i++) {
            if ($i -eq $Context.CurrentIndex) { continue }
            $w = $Context.Words[$i]
            if ($skipOptions.Contains($w)) { $i++ }
            elseif (!$w.StartsWith('-') -or ($i -gt $Context.DoubledashIndex)) {
                $UsedPaths.Add($w)
            }
        }

        gitCompleteIndexFile -Current $Current -Options ([IndexFilesOptions]::Cached) -Exclude $UsedPaths -LeadingDash:($Context.HasDoubledash())
    }
}

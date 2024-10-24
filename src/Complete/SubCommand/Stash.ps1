# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.Management.Automation;

function Complete-GitSubCommand-stash {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    $subcommands = gitResolveBuiltins $Context.Command
    [string] $subcommand = $Context.SubcommandWithoutGlobalOption()
    $ArgIndex = $Context.CommandIndex + 2
    if (!$subcommand) {
        if ($Context.CurrentIndex -eq $Context.CommandIndex + 1) {
            if (!$Context.HasDoubledash()) {
                $subcommands | gitcomp -Current $Current -DescriptionBuilder { 
                    switch ($_) {
                        'apply' { 'apply a single stashed state but do not remove the state' }
                        'clear' { 'remove all the stash entries' }
                        'drop' { 'remove a single stashed state' }
                        'pop' { 'remove a single stashed state and apply it' }
                        'branch' { 'creates and checks out a new branch' }
                        'list' { 'list the stash entries' }
                        'show' { 'show the changes recorded' }
                        'store' { 'store a given stash' }
                        'create' { 'create a stash entry' }
                        'push' { 'save your local modifications to a new stash entry and roll them back to HEAD (default)' }
                    }
                }
            }
        }

        $subcommand = 'push'
        $ArgIndex--
    }

    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command $subcommand -Current $Current
        if ($shortOpts) { return $shortOpts }

        if ($Current.StartsWith('--')) {
            $Include = switch ($subcommand) {
                'list' { $gitLogCommonOptions + $gitDiffCommonOptions }
                'show' { $gitDiffCommonOptions }
                Default { $null }
            }
            gitCompleteResolveBuiltins $Context.Command $subcommand -Current $Current -Include $Include
            return
        }
    }

    if ($subcommand -in 'branch', 'show', 'apply', 'drop', 'pop') {
        if (($subcommand -eq 'branch') -and ($ArgIndex -eq $Context.CurrentIndex)) {
            gitCompleteRefs $Current
        }
        else {
            gitCompletStashList | filterCompletionResult $Current
        }
    }
    elseif ($subcommand -eq 'push') {
        $completeOpt = [IndexFilesOptions]::Modified
        $UsedPaths = [List[string]]::new($Context.Words.Length)
        for ($i = $Context.CommandIndex + 1; $i -lt $Context.Words.Length; $i++) {
            if ($i -eq $Context.CurrentIndex) { continue }
            $w = $Context.Words[$i]
            if ($w -cin '-u', '--include-untracked') {
                $completeOpt = [IndexFilesOptions]::Updated
            }
            elseif (!$w.StartsWith('-') -or ($i -gt $Context.DoubledashIndex)) {
                $UsedPaths.Add($w)
            }
        }

        gitCompleteIndexFile -Current $Current -Options $completeOpt -Exclude $UsedPaths -LeadingDash:($Context.HasDoubledash())
    }
}

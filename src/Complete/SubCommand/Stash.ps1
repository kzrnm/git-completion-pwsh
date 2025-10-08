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
                        'export' { 'export the specified stashes' }
                        'import' { 'import the specified stashes from the specified commit, which must have been created by export' }
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
            if ($subcommand -eq 'export') {
                if ($Current -cmatch '(--[^=]+)=(.*)') {
                    $key = $Matches[1]
                    $value = $Matches[2]
                    if ($key -eq '--to-ref') {
                        gitCompleteRefs $value -Prefix "$key="
                        return
                    }
                }
            }

            $candidates = switch ($subcommand) {
                'list' { $gitLogCommonOptions + $gitDiffCommonOptions }
                'show' { $gitDiffCommonOptions }
                Default { $null }
            }
            if ($candidates) {
                $candidates | completeTipList -Current $Current -ResultType ParameterName
            }
            gitCompleteResolveBuiltins $Context.Command $subcommand -Current $Current -Exclude ($candidates | ForEach-Object ListItemText)
            return
        }
    }

    if ($subcommand -eq 'push') {
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
        return
    }
    if ($subcommand -eq 'import') {
        gitCompleteRefs $Current
        return
    }
    if ($subcommand -in 'branch', 'show', 'apply', 'drop', 'pop', 'export') {
        if ($subcommand -eq 'branch') {
            if ($ArgIndex -eq $Context.CurrentIndex) {
                gitCompleteRefs $Current
                return
            }
        }
        gitCompletStashList | filterCompletionResult $Current
        return
    }
}

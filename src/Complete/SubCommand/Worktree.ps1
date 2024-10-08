# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-worktree {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Subcommand = $Context.SubcommandWithoutGlobalOption()
    [string] $Prev = $Context.PreviousWord()
    [string] $Current = $Context.CurrentWord()

    $subcommands = gitResolveBuiltins $Context.Command

    if (!$subcommand) {
        if (!$Context.HasDoubledash()) {
            if ($Current -eq '-') {
                $script:__helpCompletion
            }
            else {
                $subcommands | gitcomp -Current $Current -DescriptionBuilder { 
                    switch ($_) {
                        'add' { 'create a worktree at <path> and checkout <commit-ish> into it' }
                        'prune' { 'prune worktree information' }
                        'list' { 'list details of each worktree' }
                        'lock' { 'lock it to prevent its administrative files from being pruned automatically' }
                        'unlock' { 'unlock a worktree' }
                        'move' { 'move a worktree to a new location' }
                        'remove' { 'remove a worktree' }
                        'repair' { 'repair worktree administrative files' }
                    }
                }
            }
        }
        return
    }
    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command -Subcommand $subcommand -Current $Current
        if ($shortOpts) { return $shortOpts }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command $subcommand -Current $Current
            return
        }
    }

    switch ($subcommand) {
        { $_ -cin 'lock', 'remove', 'unlock' } { return gitCompleteWorktreePaths $Current }
        'move' {
            if ($Context.DoubledashIndex -lt ($Context.CurrentIndex - 1)) {
                return @()
            }

            for ($i = $Context.CommandIndex + 2; $i -lt $Context.CurrentIndex; $i++) {
                switch -Wildcard ($Context.Words[$i]) {
                    '-*' { }
                    Default { return @() }
                }
            }

            gitCompleteWorktreePaths $Current
            return
        }
        'add' {
            if ($Prev -imatch '^-[^-]*b$') {
                gitCompleteRefs $Current
                return
            }

            if ($Context.DoubledashIndex -lt ($Context.CurrentIndex - 1)) {
                gitCompleteRefs $Current
                return
            }

            for ($i = $Context.CommandIndex + 2; $i -lt $Context.CurrentIndex; $i++) {
                switch -Wildcard ($Context.Words[$i]) {
                    { $_ -cmatch '^-([^-]*[bB]|-reason)$' } { $i++ }
                    '-*' { }
                    Default {
                        gitCompleteRefs $Current
                        return
                    }
                }
            }
            return @()
        }
    }
}

# __git_complete_worktree_paths
function gitCompleteWorktreePaths {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [Parameter(Mandatory, Position = 0)][AllowEmptyString()][string]$Current
    )

    __git worktree list --porcelain |
    Select-Object -Skip 2 |
    Where-Object { $_.StartsWith('worktree ') } |
    ForEach-Object { $_.Substring('worktree '.Length) } |
    completeList -Current $Current -ResultType ParameterValue
}
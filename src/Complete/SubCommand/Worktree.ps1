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

    $subcommands = gitResolveBuiltins $Context.command

    if (!$subcommand) {
        if (!$Context.HasDoubledash()) {
            if ($Current -eq '-') {
                $script:__helpCompletion
            }
            else {
                $subcommands | gitcomp -Current $Current -DescriptionBuilder { 
                    switch ($_) {
                        "add" { 'Create a worktree at <path> and checkout <commit-ish> into it' }
                        "prune" { 'Prune worktree information' }
                        "list" { 'List details of each worktree' }
                        "lock" { 'lock it to prevent its administrative files from being pruned automatically' }
                        "unlock" { 'Unlock a worktree' }
                        "move" { 'Move a worktree to a new location' }
                        "remove" { 'Remove a worktree' }
                        "repair" { 'Repair worktree administrative files' }
                    }
                }
            }
        }
        return
    }
    if (!$Context.HasDoubledash()) {
        if ($Current -eq '-') {
            return Get-GitShortOptions $Context.command -Subcommand $subcommand
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.command $subcommand -Current $Current
            return
        }
    }

    switch ($subcommand) {
        'lock' { return gitCompleteWorktreePaths $Current }
        'remove' { return gitCompleteWorktreePaths $Current }
        'unlock' { return gitCompleteWorktreePaths $Current }
        'move' {
            if ($Context.CurrentIndex -eq ($Context.commandIndex + 2)) {
                return gitCompleteWorktreePaths $Current
            }
            else {
                return @()
            }
        }
        'add' {
            if (($Prev -ieq '-b') -or ($Context.HasDoubledash())) {
                gitCompleteRefs -Current $Current
                return
            }

            for ($i = 3; $i -lt $Context.CurrentIndex; $i++) {
                switch -Wildcard ($Context.Words[$i]) {
                    '-b' { $i++ }
                    '--reason' { $i++ }
                    '-*' { }
                    Default {
                        gitCompleteRefs -Current $Current
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
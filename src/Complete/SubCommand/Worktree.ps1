using namespace System.Management.Automation;

function Complete-GitSubCommand-worktree {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        # [CommandLineContext] # For dynamic call
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Subcommand = $Context.Subcommand()
    [string] $Prev = $Context.PreviousWord()
    [string] $Current = $Context.CurrentWord()

    $subcommands = gitResolveBuiltins $Context.command

    if (-not $subcommand) {
        if ($Current -eq '-') {
            $script:__helpCompletion
            return
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
            return
        }
    }

    if ($Current -eq '-') {
        return Get-GitShortOptions $Context.command -Subcommand $subcommand
    }

    if ($Current.StartsWith('--')) {
        gitResolveBuiltins $Context.command $subcommand | gitcomp -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ $Context.command $subcommand }
        return
    }

    switch ($subcommand) {
        'lock' { return gitCompleteWorktreePaths $Current }
        'remove' { return gitCompleteWorktreePaths $Current }
        'unlock' { return gitCompleteWorktreePaths $Current }
        'move' {
            if ($Context.Words.Length -eq ($Context.commandIndex + 3)) {
                return gitCompleteWorktreePaths $Current
            }
            else {
                return @()
            }
        }
        'add' {
            if ($Prev -ieq '-b') {
                gitCompleteRefs -Current $Current
                return
            }

            $words = $Context.Words
            for ($i = 3; ($i + 1) -lt $words.Length; $i++) {
                switch -Wildcard ($words[$i]) {
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
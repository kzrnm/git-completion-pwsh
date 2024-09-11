# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-show {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )
    if ($Context.HasDoubledash()) { return }

    [string] $Current = $Context.CurrentWord()

    $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
    if ($shortOpts) { return $shortOpts }

    $result = Complete-Opts-show $Context
    if ($result) { return $result }

    gitCompleteRevlistFile $Current
}

function Complete-Opts-show {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param (
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    # Skip prev
    # -L seems difficult to implement, so skip it.
    # -G, -S <- what is these? what is __git_complete_symbol?
    $prevCandidates = switch -CaseSensitive ($Context.PreviousWord()) {
        '--diff-algorithm' { $script:gitDiffAlgorithms }
        '--diff-merges' { $script:gitDiffMergesOpts }
        '--ws-error-highlight' { $script:gitWsErrorHighlightOpts }
        '--color-moved-ws' { $script:gitColorMovedWsOpts }
    }

    if ($prevCandidates) {
        $prevCandidates | completeList -Current $Current -ResultType ParameterValue
        return
    }

    if (!$Current.StartsWith('--')) { return @() }

    if ($Current -cmatch '(--[^=]+)=(.*)') {
        $key = $Matches[1]
        $value = $Matches[2]
        $candidates = switch -CaseSensitive ($key) {
            { $_ -in @('--pretty', '--format') } {
                $script:gitLogPrettyFormats + @(gitPrettyAliases)
            }
            '--diff-algorithm' { $script:gitDiffAlgorithms }
            '--diff-merges' { $script:gitDiffMergesOpts }
            '--submodule' { $script:gitDiffSubmoduleFormats }
            '--ws-error-highlight' { $script:gitWsErrorHighlightOpts }
            '--color-moved' { $script:gitColorMovedOpts }
            '--color-moved-ws' { $script:gitColorMovedWsOpts }
        }

        if ($candidates) {
            $candidates | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
            return
        }
    }

    gitShowOpts | completeList -Current $Current
    return
}

function gitShowOpts {
    [OutputType([string[]])]
    param ()
    
    "--pretty="
    "--format="
    "--abbrev-commit"
    "--no-abbrev-commit"
    "--oneline"
    "--show-signature"
    "--expand-tabs"
    "--expand-tabs="
    "--no-expand-tabs"
    $gitLogShowOptions
    $gitDiffCommonOptions
}
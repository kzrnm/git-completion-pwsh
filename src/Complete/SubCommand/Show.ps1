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

    if ($Current -eq '-') {
        return Get-GitShortOptions $Context.command
    }

    $result = completeShowOpts $Context
    if ($result) { return $result }

    gitCompleteRevlistFile $Current
}

function completeShowOpts {
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
    $prevCandidates = switch ($Context.PreviousWord()) {
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

    if ($Current -cmatch '(--[^=]+)=.*') {
        $key = $Matches[1]
        $candidates = switch ($key) {
            '--pretty' { $script:gitLogPrettyFormats }
            '--format' { $script:gitLogPrettyFormats }
            '--diff-algorithm' { $script:gitDiffAlgorithms }
            '--diff-merges' { $script:gitDiffMergesOpts }
            '--submodule' { $script:gitDiffSubmoduleFormats }
            '--ws-error-highlight' { $script:gitWsErrorHighlightOpts }
            '--color-moved' { $script:gitColorMovedOpts }
            '--color-moved-ws' { $script:gitColorMovedWsOpts }
        }

        if ($candidates) {
            $candidates | completeList -Current $Current -Prefix "$key=" -ResultType ParameterValue -RemovePrefix
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
using namespace System.Management.Automation;

function Complete-GitSubCommand-diff {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if ($Current -eq '-') {
        return Get-GitShortOptions $Context.command
    }

    $result = Complete-Opts-diff $Context
    if ($result) { return $result }

    gitCompleteRevlistFile $Current
}

function Complete-Opts-diff {
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
            '--diff-algorithm' { $script:gitDiffAlgorithms }
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

    $script:gitDiffDifftoolOptions | completeList -Current $Current
    return
}

using namespace System.Management.Automation;

function Complete-GitSubCommand-whatchanged {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )
    $Context.command = 'log'
    Complete-GitSubCommand-log $Context
}

function Complete-GitSubCommand-log {
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

    $result = completeLogOpts $Context
    if ($result) { return $result }
    gitCompleteRevlistFile $Current
}

# __git_complete_log_opts
# Complete porcelain (i.e. not git-rev-list) options and at least some
# option arguments accepted by git-log.  Note that this same set of options
# are also accepted by some other git commands besides git-log.
function completeLogOpts {
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
        '--date' { $script:gitLogDateFormats }
        '--diff-algorithm' { $script:gitDiffAlgorithms }
        '--ws-error-highlight' { $script:gitWsErrorHighlightOpts }
        '--diff-merges' { $script:gitDiffMergesOpts }
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
            '--date' { $script:gitLogDateFormats }
            '--decorate' { 'full', 'short', 'no' }
            '--diff-algorithm' { $script:gitDiffAlgorithms }
            '--submodule' { $script:gitDiffSubmoduleFormats }
            '--ws-error-highlight' { $script:gitWsErrorHighlightOpts }
            '--no-walk' { 'sorted', 'unsorted' }
            '--diff-merges' { $script:gitDiffMergesOpts }
        }

        if ($candidates) {
            $candidates | completeList -Current $Current -Prefix "$key=" -ResultType ParameterValue -RemovePrefix
            return
        }
    }

    gitLogOpts -Merge:(gitPseudorefExists MERGE_HEAD) | completeList -Current $Current -ResultType ParameterName
    return
}

function gitLogOpts {
    [OutputType([string[]])]
    param (
        [switch]$Merge
    )
    
    $gitLogCommonOptions
    $gitLogShortlogOptions
    $gitLogGitkOptions
    $gitLogShowOptions
    '--root'
    '--topo-order'
    '--date-order'
    '--reverse'
    '--follow'
    '--full-diff'
    '--abbrev-commit'
    '--no-abbrev-commit'
    '--abbrev='
    '--relative-date'
    '--date='
    '--pretty='
    '--format='
    '--oneline'
    '--show-signature'
    '--cherry-mark'
    '--cherry-pick'
    '--graph'
    '--decorate'
    '--decorate='
    '--no-decorate'
    '--walk-reflogs'
    '--no-walk'
    '--no-walk='
    '--do-walk'
    '--parents'
    '--children'
    '--expand-tabs'
    '--expand-tabs='
    '--no-expand-tabs'
    '--clear-decorations'
    '--decorate-refs='
    '--decorate-refs-exclude='
    if ($Merge) { '--merge' }
    $gitDiffCommonOptions
}
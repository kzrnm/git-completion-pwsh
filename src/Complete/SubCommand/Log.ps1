using namespace System.Management.Automation;

function Complete-GitSubCommand-log {
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

    $result = Complete-Opts-log $Context
    if ($result) { return $result }
    gitCompleteRevlistFile $Current
}

Set-Alias Complete-GitSubCommand-whatchanged Complete-GitSubCommand-log

# __git_complete_log_opts
# Complete porcelain (i.e. not git-rev-list) options and at least some
# option arguments accepted by git-log.  Note that this same set of options
# are also accepted by some other git commands besides git-log.
function Complete-Opts-log {
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
        $candidates = switch -CaseSensitive ($key) {
            { $_ -in @('--pretty', '--format') } {
                $script:gitLogPrettyFormats + @(gitPrettyAliases)
            }
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
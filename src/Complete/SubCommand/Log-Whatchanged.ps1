# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
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

    $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
    if ($shortOpts) { return $shortOpts }

    $result = gitCompleteLogOpts $Context
    if ($result) { return $result }
    gitCompleteRevlistFile $Current
}

Set-Alias Complete-GitSubCommand-whatchanged Complete-GitSubCommand-log

# __git_complete_log_opts
# Complete porcelain (i.e. not git-rev-list) options and at least some
# option arguments accepted by git-log.  Note that this same set of options
# are also accepted by some other git commands besides git-log.
function gitCompleteLogOpts {
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
        '--date' { $script:gitLogDateFormats | completeList -Current $Current -ResultType ParameterValue; return }
        '--diff-algorithm' { $script:gitDiffAlgorithms }
        '--ws-error-highlight' { $script:gitWsErrorHighlightOpts | completeList -Current $Current -ResultType ParameterValue; return }
        '--diff-merges' { $script:gitDiffMergesOpts | completeList -Current $Current -ResultType ParameterValue; return }
    }

    if ($prevCandidates) {
        $prevCandidates.GetEnumerator() | completeTipTable -Current $Current -ResultType ParameterValue
        return
    }

    if (!$Current.StartsWith('--')) { return @() }

    if ($Current -cmatch '(--[^=]+)=(.*)') {
        $key = $Matches[1]
        $value = $Matches[2]
        $candidates = switch -CaseSensitive ($key) {
            { $_ -in @('--pretty', '--format') } {
                $script:gitLogPrettyFormats + @(gitPrettyAliases) | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue; return
            }
            '--date' { $script:gitLogDateFormats | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue; return }
            '--decorate' { 'full', 'short', 'no' | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue; return }
            '--diff-algorithm' { $script:gitDiffAlgorithms }
            '--submodule' { $script:gitDiffSubmoduleFormats }
            '--ws-error-highlight' { $script:gitWsErrorHighlightOpts | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue; return }
            '--no-walk' { 'sorted', 'unsorted' | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue; return }
            '--diff-merges' { $script:gitDiffMergesOpts | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue; return }
        }

        if ($candidates) {
            $candidates.GetEnumerator() | completeTipTable -Current $value -Prefix "$key=" -ResultType ParameterValue
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
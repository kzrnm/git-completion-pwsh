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
    gitCompleteRevlist $Current
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
        '--date' { $script:gitLogDateFormats }
        '--diff-algorithm' { $script:gitDiffAlgorithms }
        '--ws-error-highlight' { $script:gitWsErrorHighlightOpts }
        '--diff-merges' { $script:gitDiffMergesOpts }
        '--exclude' { gitCompleteLogExclude $Context $Current }
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
            { $_ -in @('--pretty', '--format') } { @(gitCompletePretty | Sort-Object) }
            '--date' { $script:gitLogDateFormats }
            '--decorate' { 'full', 'short', 'no' }
            '--diff-algorithm' { $script:gitDiffAlgorithms }
            '--submodule' { $script:gitDiffSubmoduleFormats }
            '--ws-error-highlight' { $script:gitWsErrorHighlightOpts }
            '--no-walk' { 'sorted', 'unsorted' }
            '--diff-merges' { $script:gitDiffMergesOpts }
            '--exclude' { gitCompleteLogExclude $Context $value }
        }

        if ($candidates) {
            $candidates | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
            return
        }
    }

    $Merge = $null
    if (gitPseudorefExists MERGE_HEAD) {
        $Merge = @('--merge')
    }
    $gitLogOptions | completeList -Current $Current -ResultType ParameterName -Exclude $Merge
    return
}

function gitCompleteLogExclude {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context,
        [string]
        [AllowEmptyString()]
        [Parameter(Position = 1, Mandatory)]$Current
    )

    for ($i = $Context.CurrentIndex + 1; $i -lt $Context.DoubledashIndex; $i++) {
        $type = switch -Regex ($Context.Words[$i]) {
            '^--branches($|=)' { 'branch' }
            '^--tags($|=)' { 'tag' }
            '^--remotes($|=)' { 'remote' }
            '^--glob($|=)' { 'all' }
            '^--all$' { 'all' }
        }
        if ($type) {
            break
        }
    }

    switch ($type) {
        'branch' { gitHeads $Current }
        'tag' { gitTags $Current }
        'remote' { gitRemoteHeads $Current }
        'all' { gitRefnames $Current }
        Default {
            gitRefnames $Current
            gitRefStrip $Current
        }
    }
}
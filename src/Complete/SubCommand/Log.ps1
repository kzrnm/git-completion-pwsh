using namespace System.Management.Automation;

function Complete-GitSubCommand-whatchanged {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        # [CommandLineContext] # For dynamic call
        [Parameter(Position = 0, Mandatory)]$Context
    )
    $Context.command = 'log'
    Complete-GitSubCommand-whatchanged $Context
}

function Complete-GitSubCommand-log {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        # [CommandLineContext] # For dynamic call
        [Parameter(Position = 0, Mandatory)]$Context
    )

    if ($Context.CurrentWord() -eq '-') {
        return Get-GitShortOptions $Context.command
    }

    if ($Context.HasDoubledash()) { return }
    $result = completeLogOpts $Context
    if ($result) { return $result }
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

    if (!$Current.StartsWith('--')) { return @() }

    # -L seems difficult to implement, so skip it.
    # -G, -S <- what is these? what is __git_complete_symbol?

    switch -Wildcard ($Current) {
        '--pretty=*' { $script:gitLogPrettyFormats | completeList -Current $Current -Prefix '--pretty=' -ResultType ParameterValue -RemovePrefix }
        '--format=*' { $script:gitLogPrettyFormats | completeList -Current $Current -Prefix '--format=' -ResultType ParameterValue -RemovePrefix }
        '--date=*' { $script:gitLogDateFormats | completeList -Current $Current -Prefix '--date=' -ResultType ParameterValue -RemovePrefix }
        '--decorate=*' { 'full', 'short', 'no' | completeList -Current $Current -Prefix '--decorate=' -ResultType ParameterValue -RemovePrefix }
        '--diff-algorithm=*' { 'full', 'short', 'no' | completeList -Current $Current -Prefix '--diff-algorithm=' -ResultType ParameterValue -RemovePrefix }
        Default {}
    }

    <#
	case "$cur" in
    --diff-algorithm=*)
        __gitcomp "$gitDiffAlgorithms" "" "${cur##--diff-algorithm=}"
        return
        ;;
    --submodule=*)
        __gitcomp "$gitDiffSubmoduleFormats" "" "${cur##--submodule=}"
        return
        ;;
    --ws-error-highlight=*)
        __gitcomp "$gitWsErrorHighlightOpts" "" "${cur##--ws-error-highlight=}"
        return
        ;;
    --no-walk=*)
        __gitcomp "sorted unsorted" "" "${cur##--no-walk=}"
        return
        ;;
    --diff-merges=*)
                __gitcomp "$gitDiffMergesOpts" "" "${cur##--diff-merges=}"
                return
                ;;
    --*)
        __gitcomp "
            $gitLogCommonOptions
            $gitLogShortlogOptions
            $gitLogGitkOptions
            $gitLogShowOptions
            --root --topo-order --date-order --reverse
            --follow --full-diff
            --abbrev-commit --no-abbrev-commit --abbrev=
            --relative-date --date=
            --pretty= --format= --oneline
            --show-signature
            --cherry-mark
            --cherry-pick
            --graph
            --decorate --decorate= --no-decorate
            --walk-reflogs
            --no-walk --no-walk= --do-walk
            --parents --children
            --expand-tabs --expand-tabs= --no-expand-tabs
            --clear-decorations --decorate-refs=
            --decorate-refs-exclude=
            $merge
            $gitDiffCommonOptions
            "
        return
        ;;
    #>
}

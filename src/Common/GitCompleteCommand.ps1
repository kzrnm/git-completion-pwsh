using namespace System.Management.Automation;

# __git_complete_fetch_refspecs
function gitCompleteFetchRefspecs {
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [Parameter(Mandatory)][string] $Remote,
        [string] $Prefix = "",
        [string] $Suffix = "",
        [CompletionResultType]
        $ResultType = [CompletionResultType]::ParameterValue
    )

    gitRefs -Remote $Remote -Current $Current |
    ForEach-Object { "${_}:${_}" } |
    completeList -Current $Current -Prefix $Prefix -Suffix $Suffix -ResultType $ResultType
}

# __git_complete_remote_or_refspec
function gitCompleteRemoteOrRefspec {
    [OutputType([CompletionResult[]])]
    param (
        [Parameter(Position = 0, Mandatory)]
        [CommandLineContext]
        $Context,
        [CompletionResultType]
        $ResultType = [CompletionResultType]::ParameterValue
    )

    $Command = $Context.command
    $Current = $Context.CurrentWord()

    $Prefix = ''
    $remote = ''
    $lhs = $true
    $noCompleteRefspec = $false

    $c = 1
    if ($Command -eq 'remote') { $c++ }

    for ($i = $Context.commandIndex + $c; ($i + 1) -lt $Context.Words.Length; $i++) {
        $w = $Context.Words[$i]
        if ($w -eq '--mirror') {
            if ($Command -eq 'push') {
                $noCompleteRefspec = $true
            }
        }
        elseif ($w -in '-d', '--delete') {
            if ($Command -eq 'push') {
                $lhs = $false
            }
        }
        elseif ($w -eq '--all') {
            if ($Command -eq 'push') {
                $noCompleteRefspec = $true
            }
            elseif ($Command -eq 'fetch') {
                return 
            }
        }
        elseif ($w -eq '--multiple') {
            $noCompleteRefspec = $true
            break
        }
        elseif (!$w.StartsWith('--')) {
            $remote = $w
            break
        }
    }

    if (!$remote) {
        gitRemote | completeList -Current $Current -ResultType $ResultType
        return
    }

    if ($noCompleteRefspec) { return @() }
    if ($remote -eq '.') { $remote = '' }
    
    switch -Wildcard ($Current) {
        '*:*' { 
            ($left, $right) = $Current -split ":", 2
            $Prefix = "${left}:"
            $Current = "$right"
            $lhs = $false
            break
        }
        '+*' {
            $Prefix = '+'
            $Current = $Current.Substring(1)
            break
        }
    }

    if ($Command -eq 'fetch') {
        if ($lhs) {
            gitCompleteFetchRefspecs -Remote $remote -Current $Current -Prefix $Prefix -ResultType $ResultType
        }
        else {
            gitCompleteRefs -Current $Current -Prefix $Prefix -ResultType $ResultType
        }
    }
    elseif ($Command -in @('pull', 'remote')) {
        if ($lhs) {
            gitCompleteRefs -Current $Current -Prefix $Prefix -Remote $remote -ResultType $ResultType
        }
        else {
            gitCompleteRefs -Current $Current -Prefix $Prefix -ResultType $ResultType
        }
    }
    elseif ($Command -eq 'push') {
        if ($lhs) {
            gitCompleteRefs -Current $Current -Prefix $Prefix -ResultType $ResultType
        }
        else {
            gitCompleteRefs -Current $Current -Prefix $Prefix -Remote $remote -ResultType $ResultType
        }
    }
}

function gitCompleteRefs {
    [OutputType([CompletionResult[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [string] $Remote = "",
        [string] $Prefix = "",
        [string] $Suffix = "",
        [ValidateSet('refs', 'heads', 'remote-heads')][string] $Mode = "refs",
        [switch] $dwim,
        [CompletionResultType]
        $ResultType = [CompletionResultType]::ParameterValue
    )

    switch ($Mode) {
        'refs' { 
            gitRefs -Current $Current -Remote $Remote | completeList -Current $Current -Prefix $Prefix -Suffix $Suffix -ResultType $ResultType
        }
        'heads' { 
            gitHeads -Current $Current | completeList -Current $Current -Prefix $Prefix -Suffix $Suffix -ResultType $ResultType
        }
        'remote-heads' { 
            gitRemoteHeads -Current $Current | completeList -Current $Current -Prefix $Prefix -Suffix $Suffix -ResultType $ResultType
        }
    }

    if ($dwim) {
        gitDwimRemoteHeads -Current $Current | completeList -Current $Current -Prefix $Prefix -Suffix $Suffix -ResultType $ResultType
    }
}

# __git_complete_strategy
function gitCompleteStrategy {
    param (
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Prev
    )

    $gitMergeStrategyOptions = @(
        'ours',
        'theirs',
        'subtree',
        'subtree=',
        'patience',
        'histogram',
        'diff-algorithm=',
        'ignore-space-change',
        'ignore-all-space',
        'ignore-space-at-eol',
        'renormalize',
        'no-renormalize',
        'no-renames',
        'find-renames',
        'find-renames=',
        'rename-threshold='
    )

    if ($Prev -cin @('-s', '--strategy')) {
        gitListMergeStrategies | completeList -Current $Current -ResultType ParameterValue 
        return
    }
    elseif ($Prev -cin @('-X', '--strategy-option')) {
        $gitMergeStrategyOptions | completeList -Current $Current -ResultType ParameterValue 
        return
    }

    switch -Wildcard ($Current) {
        '--strategy=*' { 
            gitListMergeStrategies | completeList -Current $Current -ResultType ParameterValue -Prefix '--strategy=' -RemovePrefix
            return
        }
        '--strategy-option=*' {
            $gitMergeStrategyOptions | completeList -Current $Current -ResultType ParameterValue -Prefix '--strategy-option=' -RemovePrefix
            return
        }
    }
    return $null
}

function gitCompleteResolveBuiltins {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory)]
        [string]
        $Current,
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [string[]]
        $Command
    )

    gitResolveBuiltins @Command | gitcomp -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ @Command }
}
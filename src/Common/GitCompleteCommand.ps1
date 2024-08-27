using namespace System.Management.Automation;

# __git_complete_fetch_refspecs
function gitCompleteFetchRefspecs {
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [Parameter(Mandatory)][string] $Remote,
        [string] $Prefix = "",
        [string] $Suffix = ""
    )

    gitRefs -Remote $Remote -Current $Current -Prefix '' -Suffix '' |
    ForEach-Object { "${_}:${_}" } |
    completeList -Current $Current -Prefix $Prefix -Suffix $Suffix
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

    if ($Command -eq 'remote') { $c++ }

    for ($i = $Context.commandIndex + 1; ($i + 1) -lt $Context.Words.Length; $i++) {
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
        elseif (-not $w.StartsWith('--')) {
            $remote = $w
            break
        }
    }

    if (-not $remote) {
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
            gitCompleteFetchRefspecs -Remote $remote -Current $Current -Prefix $Prefix
        }
        else {
            gitCompleteRefs -Current $Current -Prefix $Prefix
        }
    }
    elseif ($Command -in @('pull', 'remote')) {
        if ($lhs) {
            gitCompleteRefs -Current $Current -Prefix $Prefix -Remote $remote
        }
        else {
            gitCompleteRefs -Current $Current -Prefix $Prefix
        }
    }
    elseif ($Command -eq 'push') {
        if ($lhs) {
            gitCompleteRefs -Current $Current -Prefix $Prefix
        }
        else {
            gitCompleteRefs -Current $Current -Prefix $Prefix -Remote $remote
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
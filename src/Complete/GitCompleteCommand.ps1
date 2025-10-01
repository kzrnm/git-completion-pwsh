# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function gitCompletStashList {
    gitStashList | ForEach-Object {
        [CompletionResult]::new(
            "'$($_.Name)'",
            $_.Name,
            'ParameterValue',
            $_.Message
        )
    }
}

$__BuiltinDescriptionBuilder = ([scriptblock] { Get-GitOptionsDescription $_ @Command })
function gitCompleteResolveBuiltins {
    [OutputType([CompletionResult[]])]
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
        $Current,
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [string[]]
        $Command,
        [string[]]
        $Include = $null,
        [string[]]
        $Exclude = $null,
        [switch]
        $Check
    )

    if ($Include) {
        $Include += @(gitResolveBuiltins @Command -Check:$Check)
    }
    else {
        $Include = @(gitResolveBuiltins @Command -Check:$Check)
    }

    if ($Exclude) {
        $ex = [System.Collections.Generic.HashSet[string]]::new($Exclude.Length)
        foreach ($e in $Exclude) {
            $ex.Add($e) > $null
        }

        $Include | Where-Object {
            !$ex.Contains($_)
        } | gitcomp -Current $Current -DescriptionBuilder $__BuiltinDescriptionBuilder
    }
    else {
        $Include | gitcomp -Current $Current -DescriptionBuilder $__BuiltinDescriptionBuilder
    }
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

    $Command = $Context.Command
    $Current = $Context.CurrentWord()

    $Prefix = ''
    $remote = ''
    $lhs = $true
    $noCompleteRefspec = $false

    $c = 1
    if ($Command -eq 'remote') { $c++ }

    for ($i = $Context.CommandIndex + $c; $i -lt $Context.Words.Length; $i++) {
        if ($i -eq $Context.CurrentIndex) { continue }
        $w = $Context.Words[$i]
        if (($i -lt $Context.CurrentIndex) -and !$w.StartsWith('-')) {
            $remote = $w
            break
        }
        if ($w -eq '--multiple') {
            $noCompleteRefspec = $true
            break
        }
        elseif ($Command -eq 'push') {
            if ($w -cin '--mirror', '--all') {
                $noCompleteRefspec = $true
            }
            elseif ($w -cmatch '^-([^-]*d[^-]*|-delete)$') {
                $lhs = $false
            }
        }
        elseif (($Command -eq 'fetch') -and ($w -eq '--all')) {
            return
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'matchRef')]
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [Parameter(Mandatory, Position = 0)][AllowEmptyString()][string] $Current,
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
            $matchRef = $false
            gitRefs -Current $Current -Remote $Remote | ForEach-Object {
                if ($Current -ceq $_) {
                    $matchRef = $true
                }
                $_
            } | completeList -Current $Current -Prefix $Prefix -Suffix $Suffix -ResultType $ResultType -WithCommitMessage

            if ($Current) {
                if ($matchRef) {
                    $pp = "$Current~"
                    $skip = 1
                }
                else {
                    $pp = $Current
                    $skip = 0
                }
                gitRecentLog $Current -Skip $skip -MaxCount:(6 - $skip) | ForEach-Object {
                    [CompletionResult]::new(
                        "$Prefix$pp$Suffix",
                        $pp,
                        $ResultType,
                        $_
                    )
                    $pp = "$pp~"
                }
            }
        }
        'heads' { 
            gitHeads -Current $Current | completeList -Prefix $Prefix -Suffix $Suffix -ResultType $ResultType
        }
        'remote-heads' { 
            gitRemoteHeads -Current $Current | completeList -Prefix $Prefix -Suffix $Suffix -ResultType $ResultType
        }
    }

    if ($dwim) {
        gitDwimRemoteHeads -Current $Current | completeList -Prefix $Prefix -Suffix $Suffix -ResultType $ResultType
    }
}

# __git_complete_fetch_refspecs
function gitCompleteFetchRefspecs {
    [OutputType([CompletionResult[]])]
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

# __git_complete_strategy
function gitCompleteStrategy {
    [OutputType([CompletionResult[]])]
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

    if ($Prev -cmatch '^-([^-]*s|-strategy)$') {
        gitListMergeStrategies | completeList -Current $Current -ResultType ParameterValue 
        return
    }
    elseif ($Prev -cmatch '^-([^-]*X|-strategy-option)$') {
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

<#
.SYNOPSIS
    __git_complete_index_file
.DESCRIPTION
    __git_complete_index_file
    complete index files by ls-file.
.PARAMETER Options
    The options to to pass to ls-file.
    The exception is --committable, which finds the files appropriate commit.
#>
function gitCompleteIndexFile {
    [OutputType([CompletionResult[]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
        $Current,
        [Parameter(Mandatory)]
        [IndexFilesOptions]
        $Options,
        [Parameter()]
        [string[]]
        $Exclude,
        [switch]
        $LeadingDash
    )

    if ($Current -cmatch "^(?<prefix>.*[$DirectorySeparatorCharsRegex])(?<path>.*?)$") {
        $BaseDir = $Matches['prefix']
        $Current = $Matches['path']
    }
    else {
        $BaseDir = ''
    }
    gitIndexFiles -Options $Options -Current $Current -BaseDir $BaseDir |
    filterFiles -Exclude $Exclude |
    Sort-Object -Unique |
    completeFromFileList -Prefix $BaseDir -LeadingDash:$LeadingDash
}

# __git_complete_revlist
# __git_complete_file
# __git_complete_revlist_file
function gitCompleteRevlistFile {
    [OutputType([CompletionResult[]])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        $Current
    )

    switch -Regex ($Current) {
        '(?<prefix>.*\.{2,3}.*:)(?<file>.*)' {
            completeCurrentDirectory $Matches['file'] -Prefix $Matches['prefix']
            return
        }
        '(?<ref>[^:]+):(?<file>.*)' {
            $ref = $Matches['ref']
            $CurrentFile = $Matches['file']
            $Prefix = ''
            $BaseDir = ''

            switch -Regex ($CurrentFile) {
                { $_.StartsWith('.') } {
                    completeCurrentDirectory $CurrentFile -Prefix "${ref}:"
                    return
                }
                '(?<prefix>.+)/(?<current>[^/]*)' {
                    $CurrentFile = $Matches['current']
                    $ls = "${ref}:$($Matches['prefix'])"
                    $BaseDir = $Matches['prefix']
                    $Prefix = "${ls}/"
                }
                Default {
                    $ls = $ref
                    $Prefix = "${ref}:"
                }
            }

            gitLsTreeFile "$ls" | completeLocalFile -Current $CurrentFile -Prefix $Prefix -BaseDir $BaseDir -RemovePrefix
            return
        }
        '(?<prefix>.*\.{2,3})(?<current>.*)' {
            gitCompleteRefs $Matches['current'] -Prefix $Matches['prefix']
            return
        }
        Default {
            gitCompleteRefs $Current
            return
        }
    }
}

Set-Alias gitCompleteFile gitCompleteRevlistFile
Set-Alias gitCompleteRevlist gitCompleteRevlistFile

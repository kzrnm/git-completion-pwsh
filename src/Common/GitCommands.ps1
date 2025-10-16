# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

# https://github.com/PowerShell/PowerShell/issues/24178
if ($IsCoreCLR -and !$IsWindows) {
    $script:VerbatimArgument = '--%'
}
else {
    $script:VerbatimArgument = $null
}

function __git {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter()][string]$GitDirOverride = $null,
        [Parameter(ValueFromRemainingArguments)]$OrdinaryArgs
    )

    $Context = Get-Variable 'Context' -ValueOnly -Scope 'Script' -ErrorAction Ignore
    $gitDir = $Context.gitDir
    $gitArgs = $Context.gitCArgs

    if ($GitDirOverride) {
        $gitArgs = @("--git-dir=$GitDirOverride") + $Context.gitCArgs
    }
    elseif ($gitDir) {
        $gitArgs = @("--git-dir=$gitDir") + $Context.gitCArgs
    }
    else {
        $gitArgs = $Context.gitCArgs
    }

    $OutputEncodingBak = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        git @gitArgs @OrdinaryArgs
    }
    finally {
        [Console]::OutputEncoding = $OutputEncodingBak
    }
}

$script:__gitVersion = $null
function gitVersion {
    [OutputType([version])]
    param ()

    if ($script:__gitVersion) {
        return $script:__gitVersion
    }

    (git --version) -match 'version\s*(\d+\.\d+\.\d+)'
    [version]::TryParse($Matches[1], [ref]$script:__gitVersion) > $null
    return $script:__gitVersion
}


# Returns true if $1 matches the name of a configured remote, false otherwise.
function gitIsConfiguredRemote {
    [OutputType([bool])]
    param([Parameter(Mandatory, Position = 0)][string]$Remote)
    return @(gitRemote | Where-Object { $_ -eq $Remote })
}

function gitRemote {
    [OutputType([string[]])]
    param ()

    return @(__git remote)
}

function gitListAliases {
    [OutputType([PSCustomObject[]])]
    param()

    foreach ($kv in @((__git config -z --get-regexp "^alias\." | Out-String) -split "`0")) {
        if ($kv -match "^alias\.(?<Name>\S+)\s+(?<Value>[\s\S]*)") {
            [PSCustomObject]@{
                Name  = $Matches['Name'];
                Value = $Matches['Value'] -creplace "(`r`n|`n)", ' ';
            }
        }
    }
}

function gitParseShellArgs {
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Line
    )

    $cmd = "!printf '%s\n' $($Line.Replace("`n", ' '))"
    return @(git -c alias.cmp-shell-args=$cmd cmp-shell-args)
}

function gitGetAlias {
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)][string] $Alias
    )

    $ErrorActionPreference = 'SilentlyContinue'
    try {
        __git config --get "alias.$Alias" 2>$null
    }
    catch {
        $null
    }
}

function gitStashList {
    [OutputType([PSCustomObject[]])]
    param()

    foreach ($line in ((git stash list -z) -split '\0')) {
        if ($line -match '^([^:]+): ?(.*?)$') {
            @{
                ListItemText = $Matches[1];
                Tooltip      = $Matches[2];
            }
        }
    }
}

function gitLsTreeFile {
    [OutputType([string[]])]
    param ([Parameter(Mandatory, Position = 0)][string]$treeIsh)

    $lsTree = @(__git ls-tree "$treeIsh" -z) -split "`0"
    foreach ($line in $lsTree) {
        if ($line -cmatch '(?<mode>\S+) (?<type>\S+) (?<name>\S+)\t(?<path>.+)') {
            $path = $Matches['path']
            if ($Matches['type'] -eq 'tree') {
                $path += '/'
            }
            $path
        }
    }
}


$script:__git_merge_strategies = $null
function gitListMergeStrategies {
    [OutputType([string[]])]
    param()

    if ($script:__git_merge_strategies -is [string[]]) {
        return $script:__git_merge_strategies
    }

    function listMergeStrategies {
        param ()
        foreach ($line in @(git merge -s help 2>&1)) {
            if ($line -match 'Available strategies are: (.+)\s*\.$') {
                $Matches[1] -split " "
            }
        }
    }

    try {
        $LANG = $env:LANG
        $LC_ALL = $env:LC_ALL
        $env:LANG = "C"
        $env:LC_ALL = "C"

        return $script:__git_merge_strategies = @(listMergeStrategies)
    }
    finally {
        $env:LANG = $LANG
        $env:LC_ALL = $LC_ALL
    }
}

# -- compute config --
$script:__git_config_vars = $null
function gitConfigVars {
    [OutputType([string[]])] param()
    if ($script:__git_config_vars) {
        return $script:__git_config_vars
    }
    return $script:__git_config_vars = @(git help --config-for-completion | Sort-Object)
}

$script:__git_config_vars_all = $null
function gitConfigVarsAll {
    [OutputType([string[]])] param()
    if ($script:__git_config_vars_all) {
        return $script:__git_config_vars_all
    }
    return $script:__git_config_vars_all = @(git --no-pager help --config)
}

$script:__git_config_sections = $null
function gitConfigSections {
    [OutputType([string[]])] param()
    if ($script:__git_config_sections) {
        return $script:__git_config_sections
    }
    return $script:__git_config_sections = @(git help --config-sections-for-completion)
}

$script:__git_first_level_config_vars_for_section = $null
function gitFirstLevelConfigVarsForSection {
    [OutputType([string[]])]
    param (
        [Parameter(Position = 0, Mandatory)][string] $section
    )
    if (!$script:__git_first_level_config_vars_for_section) {
        $script:__git_first_level_config_vars_for_section = @{}
    }

    if ($script:__git_first_level_config_vars_for_section[$section]) {
        return $script:__git_first_level_config_vars_for_section[$section]
    }

    return $script:__git_first_level_config_vars_for_section[$section] = (
        gitConfigVars | ForEach-Object {
            $s = $_.Split(".")
            if (($section -eq $s[0]) -and $s[1]) {
                return $s[1]
            }
        }
    )
}

$script:__git_second_level_config_vars_for_section = $null
function gitSecondLevelConfigVarsForSection {
    [OutputType([string[]])]
    param (
        [Parameter(Position = 0, Mandatory)][string] $section
    )
    if (!$script:__git_second_level_config_vars_for_section) {
        $script:__git_second_level_config_vars_for_section = @{}
    }

    if ($script:__git_second_level_config_vars_for_section[$section]) {
        return $script:__git_second_level_config_vars_for_section[$section]
    }

    return $script:__git_second_level_config_vars_for_section[$section] = (
        gitConfigVarsAll | ForEach-Object {
            $s = $_.Split(".")
            if (($section -eq $s[0]) -and $s[2]) {
                return $s[2] 
            }
        }
    )
}

function gitAllCommands {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [string[]]
        $Categories
    )
    $list = ($Categories -join ",")
    return @(__git "--list-cmds=$list")
}

# __git_find_repo_path, gitFindRepoPath
# Discovers the path to the git repository taking any '--git-dir=<path>' and
# '-C <path>' options into account and stores it in the $__git_repo_path
# variable.
function gitRepoPath {
    [OutputType([string])]
    param()
    $Context = Get-Variable 'Context' -ValueOnly -Scope 'Script' -ErrorAction Ignore
    $gitDir = $Context.gitDir
    $gitCArgs = $Context.gitCArgs

    if ($gitCArgs) {
        return [string](__git rev-parse --absolute-git-dir 2>$null)
    }
    elseif ($gitDir) {
        return "$gitDir"
    }
    elseif ($env:GIT_DIR) {
        return $env:GIT_DIR
    }
    elseif (Test-Path -Path ".git" -PathType Container) {
        return ".git"
    }
    else {
        return [string](git rev-parse --git-dir 2>$null)
    }
}

# Lists branches from the local repository.
# 1: A prefix to be added to each listed branch (optional).
# 2: List only branches matching this word (optional; list all branches if
#    unset or empty).
# 3: A suffix to be appended to each listed branch (optional).
function gitHeads {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )

    $ignoreCase = $null
    if ($script:GitCompletionSettings.IgnoreCase) {
        $ignoreCase = '--ignore-case'
    }

    @(__git for-each-ref --format="%(refname:strip=2)" `
            $ignoreCase $VerbatimArgument `
            "refs/heads/$Current*" "refs/heads/$Current*/**")
}

# Lists branches from remote repositories.
# 1: A prefix to be added to each listed branch (optional).
# 2: List only branches matching this word (optional; list all branches if
#    unset or empty).
# 3: A suffix to be appended to each listed branch (optional).
function gitRemoteHeads {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )

    $ignoreCase = $null
    if ($script:GitCompletionSettings.IgnoreCase) {
        $ignoreCase = '--ignore-case'
    }

    @(__git for-each-ref --format="%(refname:strip=2)" `
            $ignoreCase $VerbatimArgument `
            "refs/remotes/$Current*" "refs/remotes/$Current*/**")
}

# Lists tags from the local repository.
# Accepts the same positional parameters as gitHeads() above.
function gitTags {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [string] $Prefix = '',
        [string] $Suffix = ''
    )

    $ForeachPrefix = "$Prefix".Replace('%', '%%')
    $ignoreCase = $null
    if ($script:GitCompletionSettings.IgnoreCase) {
        $ignoreCase = '--ignore-case'
    }

    @(__git for-each-ref --format="$ForeachPrefix%(refname:strip=2)$Suffix" `
            $ignoreCase $VerbatimArgument `
            "refs/tags/$Current*" "refs/tags/$Current*/**")
}

function gitRefnames {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )

    $ignoreCase = $null
    if ($script:GitCompletionSettings.IgnoreCase) {
        $ignoreCase = '--ignore-case'
    }

    @(__git for-each-ref "--format=%(refname)" `
            $ignoreCase $VerbatimArgument `
            "$Current*" "$Current*/**")
}
function gitRefStrip {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )

    $ignoreCase = $null
    if ($script:GitCompletionSettings.IgnoreCase) {
        $ignoreCase = '--ignore-case'
    }

    @(__git for-each-ref "--format=%(refname:strip=2)" `
            $ignoreCase $VerbatimArgument `
            "refs/*/$Current*" "refs/*/$Current*/**")
}


# List unique branches from refs/remotes used for 'git checkout' and 'git
# switch' tracking DWIMery.
# 1: A prefix to be added to each listed branch (optional)
# 2: List only branches matching this word (optional; list all branches if
#    unset or empty).
# 3: A suffix to be appended to each listed branch (optional).
function gitDwimRemoteHeads {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [string]$Prefix = ''
    )

    function casemap {
        [OutputType([string])]
        param (
            [Parameter(Mandatory, Position = 0)][AllowEmptyString()][string] $s
        )
        if ($script:GitCompletionSettings.IgnoreCase) {
            return $s.ToLower()
        }
        else {
            return $s
        }
    }

    $dict = [System.Collections.Specialized.OrderedDictionary]::new()
    $Current = (casemap $Current)
    $remotes = foreach ($r in @(gitRemote | Sort-Object -Descending -Unique)) {
        "refs/remotes/$(casemap $r)"
    }
    foreach ($ref in @(__git for-each-ref --format='%(refname)' refs/remotes/)) {
        foreach ($r in $remotes) {
            if ((casemap $ref).StartsWith("$r/$Current")) {
                $dict[$ref.Substring(1 + $r.Length)] = 0
            }
        }
    }
    [string[]]$dict.Keys
}

# __git_count_path_components ()
# Prints the number of slash-separated components in a path.
# 1: Path to count components of.
function countPathComponents {
    [OutputType([int])]
    param(
        [Parameter(Mandatory, Position = 0)][AllowEmptyString()][string] $Path
    )
    return ($Path.Trim('/') -replace "[^/]", "").Length + 1
}

# __git_refs
# Lists refs from the local (by default) or from a remote repository.
# It accepts 0, 1 or 2 arguments:
# 1: The remote to list refs from (optional; ignored, if set but empty).
#    Can be the name of a configured remote, a path, or a URL.
# 2: In addition to local refs, list unique branches from refs/remotes/ for
#    'git checkout's tracking DWIMery (optional; ignored, if set but empty).
# 3: A prefix to be added to each listed ref (optional).
# 4: List only refs matching this word (optional; list all refs if unset or
#    empty).
# 5: A suffix to be appended to each listed ref (optional; ignored, if set
#    but empty).
#
# Use gitCompleteRefs() instead.
function gitRefs {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Remote,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )

    $Prefix = ''
    $listRefsFrom = "path"
    $match = $Current
    $umatch = $Current
    $ignoreCase = $null

    $dir = (gitRepoPath)
    if (!$Remote) {
        if (!$dir) {
            return @()
        }
    }
    else {
        if (gitIsConfiguredRemote $Remote) {
            # configured remote takes precedence over a
            # local directory with the same name
            $listRefsFrom = "remote"
        }
        elseif (Test-Path -Path "$Remote/.git" -PathType Container) {
            $dir = "$Remote/.git"
        }
        elseif (Test-Path -Path "$Remote" -PathType Container) {
            $dir = "$Remote"
        }
        else {
            $listRefsFrom = "url"
        }
    }

    if ($script:GitCompletionSettings.IgnoreCase) {
        $ignoreCase = '--ignore-case'
        $umatch = $Current.ToUpperInvariant()
    }

    if ($listRefsFrom -eq "path") {
        if ($Current.StartsWith("^")) {
            $Current = $Current.Substring(1)
            $match = $match.Substring(1)
            $umatch = $umatch.Substring(1)
            $Prefix = '^'
        }

        if ($Current -match "\^?refs(/.*)?") {
            $format = "refname"
            $refs = @("$match*", "$match*/**")
        }
        else {
            foreach ($i in ("HEAD", "FETCH_HEAD", "ORIG_HEAD", "MERGE_HEAD", "REBASE_HEAD", "CHERRY_PICK_HEAD", "REVERT_HEAD", "BISECT_HEAD", "AUTO_MERGE")) {
                if (($i.StartsWith($match)) -or ($i.StartsWith($umatch))) {
                    if (Test-Path "$dir/$i" -PathType Leaf) {
                        "$Prefix$i"
                    }
                }
            }

            $format = "refname:strip=2"
            $refs = @("refs/tags/$match*",
                "refs/tags/$match*/**",
                "refs/heads/$match*",
                "refs/heads/$match*/**",
                "refs/remotes/$match*",
                "refs/remotes/$match*/**")
        }
        __git -GitDirOverride $dir for-each-ref "--format=$Prefix%($format)" $ignoreCase $VerbatimArgument @refs
        return
    }

    if ($Current -match "refs(/.*)?") {
        foreach ($r in @(__git ls-remote "$Remote" "$Match*")) {
            if ($r -match "(\S+)\s+(\S+)") {
                $i = $Matches[2]
                if ($i -notlike "*^{}") {
                    "$i"
                }
            }
        }
    }
    elseif ($listRefsFrom -eq "remote") {
        if ("HEAD".StartsWith($match)) {
            "HEAD"
        }
        $strip = countPathComponents "refs/remotes/$remote"

        __git for-each-ref --format="%(refname:strip=$strip)" `
            $ignoreCase $VerbatimArgument `
            "refs/remotes/$remote/$match*" "refs/remotes/$remote/$match*/**"
    }
    else {
        $querySymref = $null
        if ("HEAD".StartsWith($match)) {
            $querySymref = 'HEAD'
        }

        foreach ($r in @(__git ls-remote "$Remote" $querySymref "refs/tags/$match*" "refs/heads/$match*" "refs/remotes/$match*")) {
            if ($r -match "(\S+)\s+(\S+)") {
                $i = $Matches[2]
                if ($i -notlike "*^{}") {
                    if ($i.StartsWith('refs/')) {
                        $i.Substring("$i".IndexOf('/', 5))
                    }
                    else {
                        "$i"
                    }
                }
            }
        }
    }
}

# __git_resolve_builtins
function gitResolveBuiltins {
    [OutputType([string[]])]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [string[]]
        $Command,
        [Parameter(ParameterSetName = 'All')]
        [switch]
        $All,
        [switch]
        $Check
    )

    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        $All = [bool]$script:GitCompletionSettings.ShowAllOptions
    }

    if (!$Check -or (gitSupportParseoptHelper $Command[0])) {
        return @(gitResolveBuiltinsImpl @Command -All:([bool]$All) |
            ForEach-Object { $_ -split "\s+" } |
            Where-Object { $_ }
        )
    }
}

function gitResolveBuiltinsImpl {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, ValueFromRemainingArguments)][string[]] $Command,
        [switch] $All
    )

    if ($All) {
        $completionHelper = '--git-completion-helper-all'
    }
    else {
        $completionHelper = '--git-completion-helper'
    }

    return (git @Command $completionHelper 2>$null)
}


$script:__git_support_parseopt_helper = $null
# __git_support_parseopt_helper
function gitSupportParseoptHelper {
    [OutputType([bool])]
    param([Parameter(Mandatory, Position = 0)][string]$Command)
    if (!$script:__git_support_parseopt_helper) {
        $script:__git_support_parseopt_helper = [HashSet[string]]::new( -split ([string](git --list-cmds=parseopt)))
    }

    return $script:__git_support_parseopt_helper.Contains($Command)
}


# __git_get_config_variables
# Lists all set config variables starting with the given section prefix,
# with the prefix removed.
function gitGetConfigVariables () {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Section
    )

    foreach ($kv in @((__git config -z --get-regexp "^$Section\..*" | Out-String) -split "`0")) {
        if ($kv -match "^$Section\.(?<Name>\S+)\s+(?<Value>[\s\S]*)") {
            [PSCustomObject]@{
                ListItemText = $Matches['Name'];
                Tooltip      = $Matches['Value'] -creplace "(`r`n|`n)", ' ';
            }
        }
    }
}

# __git_pseudoref_exists
# Runs git in $__git_repo_path to determine whether a pseudoref exists.
# 1: The pseudo-ref to search
function gitPseudorefExists {
    param([Parameter(Mandatory, Position = 0)][string]$ref)

    $repoPath = (gitRepoPath)
    [string]$head = (Get-Content "$repoPath/HEAD" -ErrorAction Ignore | Select-Object -First 1)

    # If the reftable is in use, we have to shell out to 'git rev-parse'
    # to determine whether the ref exists instead of looking directly in
    # the filesystem to determine whether the ref exists. Otherwise, use
    # Bash builtins since executing Git commands are expensive on some
    # platforms.
    if ($head -eq 'ref: refs/heads/.invalid') {
        __git show-ref --exists "$ref" 1>$null 2>$null
        return $LASTEXITCODE -eq 0
    }

    return ((Get-Item "$repoPath/$ref" -ErrorAction Ignore) -is [System.IO.FileInfo])
}

function gitArchiveList {
    [CmdletBinding()]
    [OutputType([string[]])]
    param ()

    __git archive --list
}

function gitCommitMessage() {
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)]
        [string[]]
        $refs
    )
    $keyLength = 0
    $msgTable = @{}
    foreach ($line in (__git show -s @refs --oneline --no-decorate 2>$null)) {
        if ($line -cmatch '^(?<msg>(?<key>[0-9a-fA-F]+) .*)$') {
            $msgTable[$Matches['key']] = $Matches['msg']
            $keyLength = $Matches['key'].Length
        }
    }

    foreach ($line in (__git rev-parse @refs 2>$null)) {
        $msgTable[$line.Substring(0, $keyLength)]
    }
}

function gitRecentLog() {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)]
        $ref = $null,
        $MaxCount = 5,
        $Skip = 0
    )
    $line = [string](git log $ref --oneline -z "--max-count=$MaxCount" "--skip=$Skip" 2>$null)
    if ($line) {
        return $line.Split([char[]]@([char]0), [StringSplitOptions]::RemoveEmptyEntries)
    }
    return @()
}
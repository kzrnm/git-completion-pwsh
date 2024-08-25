using namespace System.Collections.Generic;

function __git {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter()]$GitDirOverride = $null,
        [Parameter(ValueFromRemainingArguments)]$OrdinaryArgs
    )

    $Context = Get-Variable 'Context' -ValueOnly -Scope 'Script' -ErrorAction Ignore
    $gitDir = $Context.gitDir
    $gitCArgs = $Context.gitCArgs

    if ($GitDirOverride) {
        $gitDirOption = "--git-dir=$GitDirOverride"
    }
    elseif ($gitDir) {
        $gitDirOption = "--git-dir=$gitDir"
    }
    else {
        $gitDirOption = $null
    }

    git $gitDirOption @gitCArgs @OrdinaryArgs
}

function isGitCompletionShowAll {
    [OutputType([bool])]
    param()
    return ($env:GIT_COMPLETION_SHOW_ALL -and ($env:GIT_COMPLETION_SHOW_ALL -ne '0'))
}
function isGitCompletionShowAllCommand {
    [OutputType([bool])]
    param()
    return ($env:GIT_COMPLETION_SHOW_ALL_COMMANDS -and ($env:GIT_COMPLETION_SHOW_ALL_COMMANDS -ne '0'))
}
function isGitCompletionIgnoreCase {
    [OutputType([bool])]
    param()
    return ($env:GIT_COMPLETION_IGNORE_CASE -and ($env:GIT_COMPLETION_IGNORE_CASE -ne '0'))
}

$script:__gitVersion = $null
function gitVersion {
    [OutputType([version])]
    param ()

    if ($script:__gitVersion) {
        return $script:__gitVersion 
    }

    (git --version) -match 'version\s(\d+\.\d+\.\d+)'
    [version]::TryParse($Matches[1], [ref]$script:__gitVersion) | Out-Null
    return $script:__gitVersion
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
        (git merge -s help 2>&1 | Where-Object { $_ -match "[Aa]vailable strategies are: " }) -match ".*:\s*(.*)\s*\." | Out-Null
        return ($Matches[1] -split " ")
    }

    try {
        $LANG = $env:LANG
        $LC_ALL = $env:LC_ALL
        $env:LANG = "C"
        $env:LC_ALL = "C"

        return $script:__git_merge_strategies = (listMergeStrategies)
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
    return $script:__git_config_vars = (git help --config-for-completion | Sort-Object)
}

$script:__git_config_vars_all = $null
function gitConfigVarsAll {
    [OutputType([string[]])] param()
    if ($script:__git_config_vars_all) {
        return $script:__git_config_vars_all
    }
    return $script:__git_config_vars_all = (git --no-pager help --config)
}

$script:__git_config_sections = $null
function gitConfigSections {
    [OutputType([string[]])] param()
    if ($script:__git_config_sections) {
        return $script:__git_config_sections
    }
    return $script:__git_config_sections = (git help --config-sections-for-completion)
}

$script:__git_first_level_config_vars_for_section = $null
function gitFirstLevelConfigVarsForSection {
    [OutputType([string[]])]
    param (
        [Parameter(Position = 0, Mandatory)][string] $section
    )
    if (-not $script:__git_first_level_config_vars_for_section) {
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
    if (-not $script:__git_second_level_config_vars_for_section) {
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

$script:__gitBuiltinCommands = $null
function gitBuiltinCommands {
    [OutputType([string[]])]
    param()
    if ($script:__gitBuiltinCommands) {
        return $script:__gitBuiltinCommands
    }
    return $script:__gitBuiltinCommands = (git "--list-cmds=builtins")
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
    return (__git "--list-cmds=$list")
}

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
        return (__git rev-parse --absolute-git-dir 2>$null)
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
        return (git rev-parse --git-dir 2>$null)
    }
}

function gitCompleteRefs {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [string] $Remote = "",
        [string] $Prefix = "",
        [string] $Suffix = "",
        [ValidateSet('refs', 'heads', 'remote-heads')][string] $Mode = "refs",
        [switch] $dwim
    )


    switch ($Mode) {
        'refs' { 
            $result = (gitRefs -Current $Current -Prefix $Prefix -Suffix $Suffix -Remote $Remote)
        }
        'heads' { 
            $result = (gitHeads -Current $Current -Prefix $Prefix -Suffix $Suffix)
        }
        'remote-heads' { 
            $result = (gitRemoteHeads -Current $Current -Prefix $Prefix -Suffix $Suffix)
        }
    }
    
    if ($dwim) {
        $result += (gitDwimRemoteHeads -Current $Current -Prefix $Prefix -Suffix $Suffix)
    }

    return [string[]]$result
}


# Lists branches from the local repository.
# 1: A prefix to be added to each listed branch (optional).
# 2: List only branches matching this word (optional; list all branches if
#    unset or empty).
# 3: A suffix to be appended to each listed branch (optional).
function gitHeads {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Prefix,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Suffix
    )

    $ForeachPrefix = "$Prefix".Replace('%', '%%')
    $ignoreCase = $null
    if (isGitCompletionIgnoreCase) {
        $ignoreCase = '--ignore-case'
    }

    __git for-each-ref --format="$ForeachPrefix%(refname:strip=2)$Suffix" `
        $ignoreCase `
        "refs/heads/$Current*" "refs/heads/$Current*/**"
}

# Lists branches from remote repositories.
# 1: A prefix to be added to each listed branch (optional).
# 2: List only branches matching this word (optional; list all branches if
#    unset or empty).
# 3: A suffix to be appended to each listed branch (optional).
function gitRemoteHeads {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Prefix,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Suffix
    )

    $ForeachPrefix = "$Prefix".Replace('%', '%%')
    $ignoreCase = $null
    if (isGitCompletionIgnoreCase) {
        $ignoreCase = '--ignore-case'
    }

    __git for-each-ref --format="$ForeachPrefix%(refname:strip=2)$Suffix" `
        $ignoreCase `
        "refs/remotes/$Current*" "refs/remotes/$Current*/**"
}

# Lists tags from the local repository.
# Accepts the same positional parameters as gitHeads() above.
function gitTags {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Prefix,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Suffix
    )

    $ForeachPrefix = "$Prefix".Replace('%', '%%')
    $ignoreCase = $null
    if (isGitCompletionIgnoreCase) {
        $ignoreCase = '--ignore-case'
    }

    __git for-each-ref --format="$ForeachPrefix%(refname:strip=2)$Suffix" `
        $ignoreCase `
        "refs/tags/$Current*" "refs/tags/$Current*/**"
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
        [Parameter(Mandatory)][AllowEmptyString()][string] $Prefix,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Suffix
    )

    $ForeachPrefix = "$Prefix".Replace('%', '%%')
    $ignoreCase = $null
    if (isGitCompletionIgnoreCase) {
        $ignoreCase = '--ignore-case'
    }

    __git for-each-ref --format="$ForeachPrefix%(refname:strip=3)$Suffix" `
        --sort="refname:strip=3" `
        $ignoreCase `
        "refs/remotes/*/$Current*" "refs/remotes/*/$Current*/**" | 
    Group-Object |
    Where-Object Count -EQ 1 |
    Select-Object -ExpandProperty Name
}


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
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Prefix,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Suffix,
        [string] $Track = ""
    )
    
    $listRefsFrom = "path"
    $match = $Current
    $umatch = $Current
    $ForeachPrefix = "$Prefix".Replace('%', '%%')
    $ignoreCase = $null

    $dir = (gitRepoPath)
    if (-not $Remote) {
        if (-not $dir) {
            return @()
        }
    }
    else {
        if (gitIsConfiguredRemote) {
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

    if (isGitCompletionIgnoreCase) {
        $ignoreCase = '--ignore-case'
        $umatch = $Current.ToUpperInvariant()
    }

    if ($listRefsFrom -eq "path") {
        if ($Current.StartsWith("^")) {
            $Prefix = "$Prefix^"
            $ForeachPrefix = "$ForeachPrefix^"
            $Current = $Current.Substring(1)
            $match = $match.Substring(1)
            $umatch = $umatch.Substring(1)
        }

        if ($Current -match "refs(/.*)?") {
            $format = "refname"
            $refs = @("$match*", "$match*/**")
            $Track = ""
        }
        else {
            foreach ($i in ("HEAD", "FETCH_HEAD", "ORIG_HEAD", "MERGE_HEAD", "REBASE_HEAD", "CHERRY_PICK_HEAD", "REVERT_HEAD", "BISECT_HEAD", "AUTO_MERGE")) {
                if (($i.StartsWith($match)) -or ($i.StartsWith($umatch))) {
                    if (Test-Path "$dir/$i" -PathType Leaf) {
                        "$Prefix$i$Suffix"
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
        __git -GitDirOverride $dir for-each-ref "--format=$ForeachPrefix%($format)$Suffix" $ignoreCase @refs
        if ($Track) {
            gitDwimRemoteHeads -Prefix $Prefix -Current $match -Suffix $Suffix
        }
        return
    }
    
    if ($Current -match "refs(/.*)?") {
        __git ls-remote "$Remote" "$Match*" | 
        ForEach-Object {
            $_ -match "(\S+)\s+(\S+)" | Out-Null
            $i = $Matches[2]
            if ($i -notlike "*^{}") {
                "$Prefix$i$Suffix"
            }
        }
    }
    elseif ($listRefsFrom -eq "remote") {
        if ("HEAD" -match "$match*") {
            "${Prefix}HEAD$Suffix"
        }
        __git for-each-ref --format="$ForeachPrefix%(refname:strip=3)$Suffix" `
            $ignoreCase `
            "refs/remotes/$remote/$match*" "refs/remotes/$remote/$match*/**"
    }
    else {
        $querySymref = $null
        if ("HEAD" -match "$match*") {
            $querySymref = 'HEAD'
        }
        __git ls-remote "$Remote" $querySymref "refs/tags/$match*" "refs/heads/$match*" "refs/remotes/$match*" |
        ForEach-Object {
            $_ -match "(\S+)\s+(\S+)" | Out-Null
            $i = $Matches[2]
            if ($i -notlike "*^{}") {
                if ($i.StartsWith('refs/*')) {
                    $j = $i.Substring('refs/*'.Length)
                    "$Prefix$j$Suffix"
                }
                else {
                    "$Prefix$i$Suffix"
                }
            }
        }
    }
}


# Returns true if $1 matches the name of a configured remote, false otherwise.
function gitIsConfiguredRemote {
    [OutputType([bool])]
    param([Parameter(Mandatory)][string]$Remote)
    return (__git remote | Where-Object { $_ -eq $Remote })
}

function gitListAliases {
    [OutputType([PSCustomObject[]])]
    param()

    __git config --get-regexp "^alias\." | ForEach-Object {
        if ($_ -match "^alias\.([^ ]+) (.*)") {
            [PSCustomObject]@{
                Name  = $Matches[1];
                Value = $Matches[2];
            }
        }
    }
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


# __git_resolve_builtins 
function gitResolveBuiltins {
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [string[]]
        $Command
    )

    return (gitResolveBuiltinsImpl @Command -All:(isGitCompletionShowAll) |
        ForEach-Object { $_ -split "\s+" } |
        Where-Object { $_ } |
        ForEach-Object {
            if ($_.EndsWith('=')) {
                $s = $_.Substring(0, $_.Length - 1)
                $s | Add-Member HasEqual $true -PassThru
            }
            else {
                $_
            }
        })
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

    return (__git @Command $completionHelper)
}


$script:__git_support_parseopt_helper = $null
# __git_support_parseopt_helper
function gitSupportParseoptHelper {
    [OutputType([bool])]
    param([Parameter(Mandatory, Position = 0)][string]$Command)
    if (-not $script:__git_support_parseopt_helper) {
        $script:__git_support_parseopt_helper = [HashSet[string]]::new([string[]]((git --list-cmds=parseopt) -split '\s+' | Where-Object { $_ }))
    }

    return $script:__git_support_parseopt_helper.Contains($Command)
}
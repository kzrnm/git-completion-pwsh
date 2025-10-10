# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-config {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $gitVersion = gitVersion
    if ($gitVersion -lt [version]::new(2, 46)) {
        Complete-GitSubCommand-config-Git2_45 $Context
        return
    }

    [string] $Prev = $Context.PreviousWord()
    [string] $Current = $Context.CurrentWord()

    $subcommands = gitResolveBuiltins $Context.Command
    [string] $subcommand = $Context.SubcommandWithoutGlobalOption()
    if ($subcommand -notin $subcommands) {
        if ($Context.HasDoubledash()) { return }
        if ($Current -eq '-') {
            $script:__helpCompletion
            return
        }
        else {
            $subcommands | gitcomp -Current $Current -DescriptionBuilder { 
                switch ($_) {
                    "list" { 'List all variables set in config file' }
                    "get" { 'Emits the value of the specified key' }
                    "set" { 'Set value for one or more config options' }
                    "unset" { 'Unset value for one or more config options' }
                    "rename-section" { 'Rename the given section to a new name' }
                    "remove-section" { 'Remove the given section from the configuration file' }
                    "edit" { 'Opens an editor to modify the specified config file' }
                }
            }
            return
        }
    }
    
    $shortOpts = Get-GitShortOptions $Context.Command -Subcommand $subcommand -Current $Current
    if ($shortOpts) { return $shortOpts }

    if ($Current.StartsWith('--')) {
        gitCompleteResolveBuiltins $Context.Command $subcommand -Current $Current
        return
    }

    if ($Prev.StartsWith('--')) {
        if ((gitResolveBuiltins $Context.Command $subcommand) -eq "$Prev=") {
            return @()
        }
    }

    switch ($subcommand) {
        'get' { completeGitConfigGetSetVariables $Context }
        'unset' { completeGitConfigGetSetVariables $Context }
        'set' {
            if ($Prev -like '*.*') {
                completeConfigVariableValue -VarName $Prev -Current $Current
            }
            else {
                completeConfigVariableName -Current $Current
            }
        }
    }

    return
}
function Complete-GitSubCommand-config-Git2_45 {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )
    $Prev = $Context.PreviousWord()
    $Current = $Context.CurrentWord()
    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command -Subcommand $subcommand -Current $Current
        if ($shortOpts) { return $shortOpts }
        if ($Prev -in ('--get', '--get-all', '--unset', '--unset-all')) {
            completeGitConfigGetSetVariables $Context
            return
        }
        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command -Current $Current
            return
        }
    }
    if ($Prev -like '*.*') {
        completeConfigVariableValue -Current $Current -VarName $Prev
    }
    else {
        completeConfigVariableName -Current $Current
    }
}

function completeGitConfigGetSetVariables {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0, Mandatory)][CommandLineContext]$Context
    )

    gitConfigGetSetVariables $Context | completeList -Current $Context.CurrentWord() -ResultType ParameterValue -DescriptionBuilder {
        Get-GitConfigVariableDescription $_
    }
}

# __git_config_get_set_variables
function gitConfigGetSetVariables {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0, Mandatory)][CommandLineContext]$Context
    )
    $file = @()
    $prev = ''
    for ($i = $Context.DoubledashIndex - 1; $i -gt $Context.CommandIndex; $i--) {
        $word = $Context.Words[$i]
        if (($word -in @('--system', '--global', '--local')) -or ($word -like "--file=*")) {
            $file = @($word)
            break
        }
        elseif ($word -cmatch '^-([^-]*f|-file)$') {
            $file = @('--file', $prev)
        }
        $prev = $word
    }
    __git config @file --name-only --list
}


# __git_complete_config_variable_name_and_value
function completeConfigOptionVariableNameAndValue {
    [OutputType([CompletionResult[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [string] $Prefix = ''
    )

    if ($Current -match '(.*)=(.*)') {
        $VarName = $Matches[1]
        return (completeConfigVariableValue -VarName $VarName -Prefix "$Prefix$VarName=" -Current $Matches[2])
    }
    else {
        return (completeConfigVariableName -Prefix $Prefix -Suffix "=" -Current $Current)
    }
}


# __git_complete_config_variable_value
function completeConfigVariableValue {
    [OutputType([CompletionResult[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [Parameter(Mandatory)][AllowEmptyString()][string] $VarName,
        [string] $Prefix = ''
    )

    function remote {
        $remotes = [string[]](__git remote)
        $remotes | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
    }

    $v = $VarName.ToLowerInvariant()
    switch -Wildcard ($v) {
        'branch.*.remote' {
            remote
            return
        }
        'branch.*.pushremote' {
            remote
            return
        }
        'branch.*.pushdefault' {
            remote
            return
        }
        'branch.*.merge' {
            gitCompleteRefs -Current $Current -Prefix $Prefix
            return
        }
        'branch.*.rebase' {
            'false', 'true', 'merges', 'interactive' | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'remote.pushdefault' {
            remote
            return
        }
        'remote.*.fetch' {
            if ($Current -eq '') {
                $result = 'refs/heads'
                return [CompletionResult]::new(
                    "${Prefix}$result",
                    $result,
                    'ParameterValue',
                    $result
                )
            }
            try {
                $remote = ($v -replace '^remote\.' -replace '\.fetch$')
                (__git ls-remote $remote 'refs/heads/*') -match "(\S+)\s+(\S+)" > $null
                # $hash = $Matches[1]
                $ref = $Matches[2]
                $result = "${ref}:refs/remotes/$remote/$($ref -replace '^refs/heads/')"
                return [CompletionResult]::new(
                    "${Prefix}$result",
                    $result,
                    'ParameterValue',
                    $result
                )
            }
            catch {
                # not found
            }
            return
        }
        'remote.*.push' {
            __git for-each-ref --format='%(refname):%(refname)' refs/heads | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'pull.twohead' {
            gitListMergeStrategies | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'pull.octopus' {
            gitListMergeStrategies | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'color.pager' {
            'false', 'true' | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'color.*.*' {
            'normal', 'black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white', 'bold', 'dim', 'ul', 'blink', 'reverse' | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'color.*' {
            'false', 'true', 'always', 'never', 'auto' | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'diff.submodule' {
            $script:gitDiffSubmoduleFormats | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'diff.algorithm' {
            $script:gitDiffAlgorithms | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'http.proxyAuthMethod' {
            $gitHttpProxyAuthMethod | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
        }
        'help.format' {
            'man', 'info', 'web', 'html' | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'log.date' {
            $script:gitLogDateFormats | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'sendemail.aliasfiletype' {
            'mutt', 'mailrc', 'pine', 'elm', 'gnus' | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'sendemail.confirm' {
            $script:gitSendEmailConfirmOptions | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'sendemail.suppresscc' {
            $script:gitSendEmailSuppressccOptions | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'sendemail.transferencoding' {
            '7bit', '8bit', 'quoted-printable', 'base64' | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        # git-completion.bash does not complete below cases.
        'merge.conflictStyle' {
            $script:gitConflictSolver | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'push.recurseSubmodules' {
            $script:gitPushRecurseSubmodules | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'fetch.recurseSubmodules' {
            $script:gitFetchRecurseSubmodules | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'diff.colorMoved' {
            $script:gitColorMovedOpts | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'diff.colorMovedWS' {
            $script:gitColorMovedWsOpts | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'diff.wsErrorHighlight' {
            $script:gitWsErrorHighlightOpts | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
            return
        }
        'column.*' {
            if ($v.Substring(7) -cin @('ui', 'branch', 'clean', 'status', 'tag')) {
                $script:gitColumnUiOptions | completeList -Current $Current -Prefix $Prefix -ResultType ParameterValue
                return
            }
        }
    }
}

# __git_complete_config_variable_name
function completeConfigVariableName {
    [OutputType([CompletionResult[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [string] $Prefix = '',
        [string] $Suffix = ''
    )

    $DescriptionBuilder = [scriptblock] {
        Get-GitConfigVariableDescription $_
    }

    if ($Current -match "(branch|guitool|difftool|man|mergetool|remote|submodule|url)\.(.*)\.([^\.]*)") {
        $section = $Matches[1]
        $second = $Matches[2]
        gitSecondLevelConfigVarsForSection $section | ForEach-Object {
            "$section.$second.$_"
        } | completeList -Current $Current -Prefix $Prefix -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix
        return
    }
    if ($Current -match "branch\.(.*)") {
        $section = 'branch'
        $second = $Matches[1]
        gitHeads -Current $second | ForEach-Object { "$section.$_." } | completeList -DescriptionBuilder $DescriptionBuilder
        gitFirstLevelConfigVarsForSection $section | ForEach-Object {
            "$section.$_"
        } | completeList -Current $Current -Prefix $Prefix -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix
        return
    }
    if ($Current -match "pager\.(.*)") {
        $section = 'pager'
        $second = $Matches[1]
        gitAllCommands main others alias nohelpers | ForEach-Object {
            "$section.$_"
        } | completeList -Current $Current -Prefix $Prefix -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix
        return
    }
    if ($Current -match "remote\.(.*)") {
        $section = 'remote'
        $second = $Matches[1]
        
        __git remote | Where-Object {
            $_.StartsWith($second) 
        } | ForEach-Object {
            "$section.$_."
        } | completeList -Current $Current -Prefix $Prefix -DescriptionBuilder $DescriptionBuilder

        gitFirstLevelConfigVarsForSection $section | ForEach-Object {
            "$section.$_"
        } | completeList -Current $Current -Prefix $Prefix -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix
        return
    }
    if ($Current -match "submodule\.(.*)") {
        $section = 'submodule'
        $second = $Matches[1]
        $gitTopPath = (__git rev-parse --show-toplevel)

        __git config -f "$gitTopPath/.gitmodules" --name-only --list 2>$null |
        ForEach-Object {
            if ($_ -match 'submodule\.(.*)\.path') {
                $sub = $Matches[1]
                "$section.$sub."
            }
        } | completeList -Current $Current -Prefix $Prefix -DescriptionBuilder $DescriptionBuilder

        gitFirstLevelConfigVarsForSection $section | ForEach-Object {
            "$section.$_"
        } | completeList -Current $Current -Prefix $Prefix -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix
        return
    }
    if ($Current -match "([^\.]*)\.(.*)") {
        $section = $Matches[1]
        gitConfigVars | Where-Object { !$_.EndsWith('.') } | completeList -Current $Current -Prefix $Prefix -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix
        return
    }
    else {
        gitConfigSections | ForEach-Object { "$_." } | completeList -Current $Current -Prefix $Prefix -DescriptionBuilder $DescriptionBuilder
    }
    return
}

function Complete-GitSubCommand-config {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        # [CommandLineContext] # For dynamic call
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $gitVersion = gitVersion
    if ($gitVersion -lt [version]::new(2, 46)) {
        Complete-GitSubCommand-config-Git2_45 $Context
        return
    }

    $Prev = $Context.PreviousWord
    $Current = $Context.CurrentWord

    if ($Current -eq '-') {
        return Get-GitConfigShortOptions
    }

    $subcommands = gitResolveBuiltins $Context.command
    $subcommand = $Context.Subcommand()
    if ($subcommand -notin $subcommands) {
        $subcommands | gitcomp -Current $Current -DescriptionBuilder { param($c); Get-GitConfigSubcommandDescription $c }
        return
    }
    if ($Current.StartsWith('--')) {
        gitResolveBuiltins $Context.command $subcommand | gitcomp -Current $Current -DescriptionBuilder { param($c); Get-GitConfigOptionsDescription -Subcommand $subcommand $c }
        return
    }

    switch ($subcommand) {
        'get' { completeGitConfigGetSetVariables $Context -Current $Current }
        'unset' { completeGitConfigGetSetVariables $Context -Current $Current }
    }

    return
    return @(
        [System.Management.Automation.CompletionResult]::new(
            "branch.",
            "branch.",
            'ParameterValue',
            "branch."
        ),
        [System.Management.Automation.CompletionResult]::new(
            "merge.",
            "merge.",
            'ParameterValue',
            "merge."
        )
    )
}
function Complete-GitSubCommand-config-Git2_45 {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )
    $Prev = $Context.PreviousWord
    $Current = $Context.CurrentWord

    if ($Current -eq '-') {
        return Get-GitConfigShortOptions
    }

    if ($Prev -in ('--get', '--get-all', '--unset', '--unset-all')) {
        completeGitConfigGetSetVariables $Context -Current $Current
    }
    elseif ($Prev -like '*.*') {
        completeConfigVariableValue -Current $Current -VarName $Prev
    }
    elseif ($Current.StartsWith('--')) {
        gitResolveBuiltins $Context.command | gitcomp -Current $Current -DescriptionBuilder { param($c); Get-GitConfigOptionsDescription $c }
    }
    else {
        completeConfigVariableName -Current $Current -Suffix ' '
    }
}

function completeGitConfigGetSetVariables {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0, Mandatory)][CommandLineContext]$Context,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )
    
    gitConfigGetSetVariables $Context | filterCompletionResult -Current $Current | ForEach-Object {
        $desc = Get-GitConfigDescription $_
        if (-not $desc) { $desc = $_ }

        [System.Management.Automation.CompletionResult]::new(
            $_,
            $_,
            'ParameterValue',
            $desc
        )
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
    for ($i = $Context.Words.Length - 1; $i -gt $Context.commandIndex ; $i--) {
        $word = $Context.Words[$i]
        if (($word -in @('--system', '--global', '--local')) -or ($word -like "--file=*")) {
            $file = @($word)
            break
        }
        elseif ($word -in @('-f', '--file')) {
            $file = @($word, $prev)
        }
        $prev = $word
    }
    __git config @file --name-only --list
}


# __git_complete_config_variable_name_and_value
function completeConfigOptionVariableNameAndValue {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )

    if ($Current -match '(.*)=(.*)') {
        $VarName = $Matches[1]
        return (completeConfigVariableValue -VarName $VarName -Prefix "$VarName=" -Current $Matches[2])
    }
    else {
        return (completeConfigVariableName -Suffix "=" -Current $Current)
    }
}


# __git_complete_config_variable_value
function completeConfigVariableValue {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [Parameter(Mandatory)][AllowEmptyString()][string] $VarName,
        [string] $Prefix = ''
    )

    function completeValue {
        [OutputType([System.Management.Automation.CompletionResult[]])]
        param(
            [Parameter(ValueFromRemainingArguments = $true)]
            [string[]]
            $Candidates
        )
        $Candidates |
        Where-Object {
            $_.StartsWith($Current)
        } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                "${Prefix}$_",
                $_,
                'ParameterValue',
                $_
            )
        }
    }

    function remote {
        $remotes = [string[]](__git remote)
        completeValue @remotes
    }

    switch -Wildcard ($VarName.ToLowerInvariant()) {
        "branch.*.remote" {
            remote
            return
        }
        "branch.*.pushremote" {
            remote
            return
        }
        "branch.*.pushdefault" {
            remote
            return
        }
        "branch.*.merge" {
            $params = [string[]](gitCompleteRefs -Current $Current)
            completeValue @params
            return
        }
        "branch.*.rebase" {
            completeValue "false" "true" "merges" "interactive"
            return
        }
        "remote.pushdefault" {
            remote
            return
        }
        "remote.*.fetch" {
            if ($Current -eq "") {
                $result = "refs/heads"
                return [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}$result",
                    $result,
                    'ParameterValue',
                    $result
                )
            }
            try {
                $remote = ($VarName -replace "^remote\." -replace "\.fetch$")
                (__git ls-remote $remote 'refs/heads/*') -match "(\S+)\s+(\S+)" | Out-Null
                # $hash = $Matches[1]
                $ref = $Matches[2]
                $result = "${ref}:refs/remotes/$remote/$($ref -replace '^refs/heads/')"
                return [System.Management.Automation.CompletionResult]::new(
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
        "remote.*.push" {
            $params = [string[]](__git for-each-ref --format='%(refname):%(refname)' refs/heads)
            completeValue @params
            return
        }
        "pull.twohead" {
            $params = [string[]](gitListMergeStrategies)
            completeValue @params
            return
        }
        "pull.octopus" {
            $params = [string[]](gitListMergeStrategies)
            completeValue @params
            return
        }
        "color.pager" {
            completeValue "false" "true"
            return
        }
        "color.*.*" {
            completeValue "normal" "black" "red" "green" "yellow" "blue" "magenta" "cyan" "white" "bold" "dim" "ul" "blink" "reverse"
            return
        }
        "color.*" {
            completeValue "false" "true" "always" "never" "auto"
            return
        }
        "diff.submodule" {
            completeValue @script:gitDiffSubmoduleFormats
            return
        }
        "diff.algorithm" {
            return (
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}default",
                    'default',
                    'ParameterValue',
                    'The basic greedy diff algorithm.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}myers",
                    'myers',
                    'ParameterValue',
                    'The basic greedy diff algorithm. Currently, this is the default.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}minimal",
                    'minimal',
                    'ParameterValue',
                    'Spend extra time to make sure the smallest possible diff is produced.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}patience",
                    'patience',
                    'ParameterValue',
                    'Use "patience diff" algorithm when generating patches.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}histogram",
                    'histogram',
                    'ParameterValue',
                    'This algorithm extends the patience algorithm to "support low-occurrence common elements".'
                ) | Where-Object {
                    $_.ListItemText.StartsWith($Current)
                }
            )
        }
        "http.proxyAuthMethod" {
            return (
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}anyauth",
                    'anyauth',
                    'ParameterValue',
                    'Automatically pick a suitable authentication method.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}basic",
                    'basic',
                    'ParameterValue',
                    'HTTP Basic authentication.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}digest",
                    'digest',
                    'ParameterValue',
                    'HTTP Digest authentication; this prevents the password from being transmitted to the proxy in clear text.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}negotiate",
                    'negotiate',
                    'ParameterValue',
                    ' GSS-Negotiate authentication (compare the --negotiate option of curl).'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "${Prefix}ntlm",
                    'ntlm',
                    'ParameterValue',
                    'NTLM authentication (compare the --ntlm option of curl).'
                ) | Where-Object {
                    $_.ListItemText.StartsWith($Current)
                }
            )
        }
        "help.format" {
            completeValue "man" "info" "web" "html"
            return
        }
        "log.date" {
            completeValue @script:gitLogDateFormats
            return
        }
        "sendemail.aliasfiletype" {
            completeValue "mutt" "mailrc" "pine" "elm" "gnus"
            return
        }
        "sendemail.confirm" {
            completeValue @script:gitSendEmailConfirmOptions
            return
        }
        "sendemail.suppresscc" {
            completeValue @script:gitSendEmailSuppressccOptions
            return
        }
        "sendemail.transferencoding" {
            completeValue "7bit" "8bit" "quoted-printable" "base64"
            return
        }
    }
}

# __git_complete_config_variable_name
function completeConfigVariableName {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current,
        [string] $Suffix = '='
    )

    $DescriptionBuilder = [scriptblock] {
        param($Candidate)

        Get-GitConfigDescription $Candidate
    }

    if ($Current -match "(branch|guitool|difftool|man|mergetool|remote|submodule|url)\.(.*)\.([^\.]*)") {
        $section = $Matches[1]
        $second = $Matches[2]
        $params = [string[]](gitSecondLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$second.$_"
            }
        )
        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix @params
        return
    }
    if ($Current -match "branch\.(.*)") {
        $section = 'branch'
        $second = $Matches[1]
        $params1 = [string[]](gitHeads -Prefix "$section." -Current $second -Suffix ".")
        $params2 = [string[]](gitFirstLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$_"
            }
        )
        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder @params1
        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix @params2
        return
    }
    if ($Current -match "pager\.(.*)") {
        $section = 'pager'
        $second = $Matches[1]
        $params = [string[]](gitAllCommands main others alias nohelpers | ForEach-Object {
                "$section.$_"
            }
        )
        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix @params
        return
    }
    if ($Current -match "remote\.(.*)") {
        $section = 'remote'
        $second = $Matches[1]
        $params1 = [string[]](__git remote | Where-Object {
                $_.StartsWith($second) 
            } | ForEach-Object {
                "$section.$_."
            }
        )
        $params2 = [string[]](gitFirstLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$_"
            }
        )

        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder @params1
        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix @params2
        return
    }
    if ($Current -match "submodule\.(.*)") {
        $section = 'submodule'
        $second = $Matches[1]
        $gitTopPath = (__git rev-parse --show-toplevel)
        
        $params1 = [string[]](__git config -f "$gitTopPath/.gitmodules" --name-only --list |
            ForEach-Object {
                if ($_ -match 'submodule\.(.*)\.path') {
                    $sub = $Matches[1]
                    "$section.$sub."
                }
            }
        )
        $params2 = [string[]](gitFirstLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$_"
            }
        )
        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder @params1
        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix @params2
        return
    }
    if ($Current -match "([^\.]*)\.(.*)") {
        $section = $Matches[1]
        $params = [string[]](gitConfigVars | Where-Object { -not $_.EndsWith('.') })
        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder -Suffix $Suffix @params
        return
    }
    else {
        $params = [string[]](gitConfigSections | ForEach-Object { "$_." })
        completeList -Current $Current -DescriptionBuilder $DescriptionBuilder @params
    }
    return
}

# __git_complete_config_variable_name_and_value
function completeConfigOptionVariableNameAndValue {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )

    if ($Current -match '(.*)=(.*)') {
        return (completeConfigVariableValue -VarName $Matches[1] -VarOp '=' -Current $Matches[2])
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
        [string] $VarName = '',
        [string] $VarOp = ''
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
                "$VarName${VarOp}$_",
                $_,
                "ParameterValue",
                $_
            )
        }
    }

    function remote {
        $remotes = (__git remote)
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
            $params = (gitCompleteRefs -Current $Current)
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
                    "$VarName${VarOp}$result",
                    $result,
                    "ParameterValue",
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
                    "$VarName${VarOp}$result",
                    $result,
                    "ParameterValue",
                    $result
                )
            }
            catch {
                # not found
            }
            return
        }
        "remote.*.push" {
            $params = (__git for-each-ref --format='%(refname):%(refname)' refs/heads)
            completeValue @params
            return
        }
        "pull.twohead" {
            $params = (gitListMergeStrategies)
            completeValue @params
            return
        }
        "pull.octopus" {
            $params = (gitListMergeStrategies)
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
                    "$VarName${VarOp}default",
                    'default',
                    "ParameterValue",
                    'The basic greedy diff algorithm.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "$VarName${VarOp}myers",
                    'myers',
                    "ParameterValue",
                    'The basic greedy diff algorithm. Currently, this is the default.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "$VarName${VarOp}minimal",
                    'minimal',
                    "ParameterValue",
                    'Spend extra time to make sure the smallest possible diff is produced.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "$VarName${VarOp}patience",
                    'patience',
                    "ParameterValue",
                    'Use "patience diff" algorithm when generating patches.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "$VarName${VarOp}histogram",
                    'histogram',
                    "ParameterValue",
                    'This algorithm extends the patience algorithm to "support low-occurrence common elements".'
                ) | Where-Object {
                    $_.ListItemText.StartsWith($Current)
                }
            )
        }
        "http.proxyAuthMethod" {
            return (
                [System.Management.Automation.CompletionResult]::new(
                    "$VarName${VarOp}anyauth",
                    'anyauth',
                    "ParameterValue",
                    'Automatically pick a suitable authentication method.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "$VarName${VarOp}basic",
                    'basic',
                    "ParameterValue",
                    'HTTP Basic authentication.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "$VarName${VarOp}digest",
                    'digest',
                    "ParameterValue",
                    'HTTP Digest authentication; this prevents the password from being transmitted to the proxy in clear text.'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "$VarName${VarOp}negotiate",
                    'negotiate',
                    "ParameterValue",
                    ' GSS-Negotiate authentication (compare the --negotiate option of curl).'
                ),
                [System.Management.Automation.CompletionResult]::new(
                    "$VarName${VarOp}ntlm",
                    'ntlm',
                    "ParameterValue",
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

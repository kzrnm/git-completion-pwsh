# __git_complete_config_variable_name_and_value
function completeConfigVariableNameAndValue {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )

    if ($Current -match '(.*)=(.*)') {
        return (completeConfigVariableValue -VarName $Matches[1] -Current $Matches[2])
    }
    else {
        return (completeConfigVariableName -Suffix "=" -Current $Current)
    }
}


# __git_complete_config_variable_value
function completeConfigVariableValue {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [Parameter(Mandatory)][string] $VarName,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Current
    )

    function completeValue {
        [OutputType([System.Management.Automation.CompletionResult[]])]
        param(
            [Parameter(ValueFromRemainingArguments = $true)]
            [string[]]
            $Candidates
        )
        $Candidates -clike "$Current*" |
        ForEach-Object { 
            [System.Management.Automation.CompletionResult]::new(
                "$VarName=$_",
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
                    "$VarName=$result",
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
                    "$VarName=$result",
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
            completeValue @gitDiffSubmoduleFormats
            return
        }
        "help.format" {
            completeValue "man" "info" "web" "html"
            return
        }
        "log.date" {
            completeValue @gitLogDateFormats
            return
        }
        "sendemail.aliasfiletype" {
            completeValue "mutt" "mailrc" "pine" "elm" "gnus"
            return
        }
        "sendemail.confirm" {
            completeValue @gitSendEmailConfirmOptions
            return
        }
        "sendemail.suppresscc" {
            completeValue @gitSendEmailSuppressccOptions
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

    if ($Current -match "(branch|guitool|difftool|man|mergetool|remote|submodule|url)\.(.*)\.([^\.]*)") {
        $section = $Matches[1]
        $second = $Matches[2]
        $params = [string[]](gitSecondLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$second.$_$Suffix"
            }
        )
        completeList @params
        return
    }
    if ($Current -match "branch\.(.*)") {
        $section = 'branch'
        $second = $Matches[1]
        $params1 = [string[]](gitHeads -Prefix "$section." -Current $second -Suffix ".")
        $params2 = [string[]](gitFirstLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$_$Suffix"
            }
        )
        completeList @params1 @params2
        return
    }
    if ($Current -match "pager\.(.*)") {
        $section = 'pager'
        $second = $Matches[1]
        $params = [string[]](gitAllCommands main others alias nohelpers | ForEach-Object { "$section.$_$Suffix" })
        completeList @params
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
                "$section.$_$Suffix"
            }
        )

        completeList @params1 @params2
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
                "$section.$_$Suffix"
            }
        )
        completeList @params1 @params2
        return
    }
    if ($Current -match "([^\.]*)\.(.*)") {
        $section = $Matches[1]
        $params = [string[]](gitConfigVars | ForEach-Object { "$_$Suffix" })
        completeList @params
        return
    }
    else {
        $params = [string[]](gitConfigSections | ForEach-Object { "$_." })
        completeList @params
    }
    return
}

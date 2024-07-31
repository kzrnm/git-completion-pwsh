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
            completeValue (gitCompleteRefs -Current $Current)
            return
        }
        "branch.*.rebase" {
            completeValue "false", "true", "merges", "interactive"
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
            completeValue (__git for-each-ref --format='%(refname):%(refname)' refs/heads)
            return
        }
        "pull.twohead" {
            completeValue (gitListMergeStrategies)
            return
        }
        "pull.octopus" {
            completeValue (gitListMergeStrategies)
            return
        }
        "color.pager" {
            completeValue "false", "true"
            return
        }
        "color.*.*" {
            completeValue "normal", "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white", "bold", "dim", "ul", "blink", "reverse"
            return
        }
        "color.*" {
            completeValue "false", "true", "always", "never", "auto"
            return
        }
        "diff.submodule" {
            completeValue $gitDiffSubmoduleFormats
            return
        }
        "help.format" {
            completeValue "man", "info", "web", "html"
            return
        }
        "log.date" {
            completeValue $gitLogDateFormats
            return
        }
        "sendemail.aliasfiletype" {
            completeValue "mutt", "mailrc", "pine", "elm", "gnus"
            return
        }
        "sendemail.confirm" {
            completeValue $gitSendEmailConfirmOptions
            return
        }
        "sendemail.suppresscc" {
            completeValue $gitSendEmailSuppressccOptions
            return
        }
        "sendemail.transferencoding" {
            completeValue "7bit", "8bit", "quoted-printable", "base64"
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
        completeList (gitSecondLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$second.$_$Suffix"
            }
        )
        return
    }
    if ($Current -match "branch\.(.*)") {
        $section = 'branch'
        $second = $Matches[1]
        completeList (gitHeads -Prefix "$section." -Current $second -Suffix ".")
        completeList (gitFirstLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$_$Suffix"
            }
        )
        return
    }
    if ($Current -match "pager\.(.*)") {
        $section = 'pager'
        $second = $Matches[1]
        completeList (gitAllCommands "main", "others", "alias", "nohelpers" | ForEach-Object { "$section.$_$Suffix" })
        return
    }
    if ($Current -match "remote\.(.*)") {
        $section = 'remote'
        $second = $Matches[1]
        completeList (__git remote | Where-Object {
                $_.StartsWith($second) 
            } | ForEach-Object {
                "$section.$_."
            }
        )
        completeList (gitFirstLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$_$Suffix"
            }
        )
        return
    }
    if ($Current -match "submodule\.(.*)") {
        $section = 'submodule'
        $second = $Matches[1]
        $gitTopPath = (__git rev-parse --show-toplevel)
        
        completeList (__git config -f "$gitTopPath/.gitmodules" --name-only --list |
            ForEach-Object {
                if ($_ -match 'submodule\.(.*)\.path') {
                    $sub = $Matches[1]
                    "$section.$sub."
                }
            }
        )
        completeList (gitFirstLevelConfigVarsForSection $section | ForEach-Object {
                "$section.$_$Suffix"
            }
        )
        return
    }
    if ($Current -match "([^\.]*)\.(.*)") {
        $section = $Matches[1]
        completeList (gitConfigVars | ForEach-Object { "$_$Suffix" })
        return
    }
    completeList (gitConfigSections | ForEach-Object { "$_." })
    return
}

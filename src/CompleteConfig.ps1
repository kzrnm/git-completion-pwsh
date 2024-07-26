# __git_complete_config_variable_name_and_value
[System.Management.Automation.CompletionResult]
function completeConfigVariableNameAndValue {
    param(
        [Parameter(Mandatory)][string] $Current
    )


    if ($Current -match '(.*)=(.*)') {
        return (completeConfigVariableValue -VarName $Matches[1] -Current $Matches[2])
    }
    else {
    }

    return $null
    # TODO: 
    # case "$cur_" in
    # *=*)
    # 	__git_complete_config_variable_value \
    # 		--varname="${cur_%%=*}" --cur="${cur_#*=}"
    # 	;;
    # *)
    # 	__git_complete_config_variable_name --cur="$cur_" --sfx='='
    # 	;;
    # esac
}


# __git_complete_config_variable_value
[System.Management.Automation.CompletionResult[]]
function completeConfigVariableValue {
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
        $Candidates |
        Where-Object { $_ -like "$Current*" } |
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
        completeValue (__git remote)
    }

    switch -Wildcard ($VarName.ToLowerInvariant()) {
        "branch.*.remote" {
            remote
        }
        "branch.*.pushremote" {
            remote
        }
        "branch.*.pushdefault" {
            remote
        }
        "branch.*.merge" {
            completeValue (gitCompleteRefs -Current $Current)
        }
        "branch.*.rebase" {
            completeValue "false", "true", "merges", "interactive"
        }
        "remote.pushdefault" {
            remote
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
        }
        "remote.*.push" {
            completeValue (__git for-each-ref --format='%(refname):%(refname)' refs/heads)
        }
        "pull.twohead" {
            completeValue (gitListMergeStrategies)
        }
        "pull.octopus" {
            completeValue (gitListMergeStrategies)
        }
        "color.pager" {
            completeValue "false", "true"
        }
        "color.*.*" {
            completeValue "normal", "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white", "bold", "dim", "ul", "blink", "reverse"
        }
        "color.*" {
            completeValue "false", "true", "always", "never", "auto"
        }
        "diff.submodule" {
            completeValue $gitDiffSubmoduleFormats
        }
        "help.format" {
            completeValue "man", "info", "web", "html"
        }
        "log.date" {
            completeValue $gitLogDateFormats
        }
        "sendemail.aliasfiletype" {
            completeValue "mutt", "mailrc", "pine", "elm", "gnus"
        }
        "sendemail.confirm" {
            completeValue $gitSendEmailConfirmOptions
        }
        "sendemail.suppresscc" {
            completeValue $gitSendEmailSuppressccOptions
        }
        "sendemail.transferencoding" {
            completeValue "7bit", "8bit", "quoted-printable", "base64"
        }
    }
}

# __git_complete_config_variable_name
[System.Management.Automation.CompletionResult]
function completeConfigVariableName {
    param(
        [Parameter(Mandatory)][string] $VarName,
        [Parameter][string] $Suffix = '-'
    ) 
    if ($Current -is [string]) {
        $cur = $Current
    }
    else {
        $cur = $CurrentWord
    }

    if ($cur -match '(.*)=(.*)') {

    }
    else {
            
    }
    return $null
    # TODO: 
    # case "$cur_" in
    # *=*)
    # 	__git_complete_config_variable_value \
    # 		--varname="${cur_%%=*}" --cur="${cur_#*=}"
    # 	;;
    # *)
    # 	__git_complete_config_variable_name --cur="$cur_" --sfx='='
    # 	;;
    # esac
}

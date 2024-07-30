. $PSScriptRoot/GitCommands.ps1
. $PSScriptRoot/GitStatics.ps1
. $PSScriptRoot/CompletionUtil.ps1
. $PSScriptRoot/CompleteConfig.ps1
. $PSScriptRoot/CompleteSubCommands.ps1

function WriteLog {
    param([Parameter(Position = 0)]$Object)
    
    if ($env:GitCompletionDubugPath) {
        $Object >> $env:GitCompletionDubugPath
    }
}

# __git_main
function Complete-Git-Ast {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [System.Management.Automation.Language.CommandAst]
        $CommandAst,
        [int]
        $CursorPosition
    )

    if ($env:GitCompletionDubugPath -and (-not $env:GitCompletionDubugKeep)) {
        $null > $env:GitCompletionDubugPath
    }

    $CommandAst = $CommandAst
    $script:CursorPosition = $CursorPosition
    $script:Words = ($CommandAst.CommandElements | Select-Object -ExpandProperty Extent | Select-Object -ExpandProperty Text)

    $cw = $CommandAst.CommandElements.Count
    $pr = $script:Words[$script:Words.Count - 1]
    $cr = ''

    for ($i = 1; $i -lt $CommandAst.CommandElements.Count; $i++) {
        $extent = $CommandAst.CommandElements[$i].Extent

        if ($CursorPosition -lt $extent.StartOffset) {
            # The cursor is within whitespace between the previous and current words.
            $pr = $commandAst.CommandElements[$i - 1].Extent.Text
            $cw = $i
            break
        }
        elseif ($CursorPosition -le $extent.EndOffset) {
            $cr = $extent.Text
            $pr = $commandAst.CommandElements[$i - 1].Extent.Text
            $cw = $i
            break
        }
    }

    $script:WordPosition = $cw
    $script:CurrentWord = $cr
    $script:PreviousWord = $pr

    WriteLog "CommandAst=$CommandAst"
    Complete-Git `
        -CursorPosition $CursorPosition `
        -Words $Words `
        -WordPosition $WordPosition `
        -CurrentWord $CurrentWord `
        -PreviousWord $PreviousWord
}

function Complete-Git {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [int][Parameter(Mandatory)]$CursorPosition,
        [string[]][AllowEmptyCollection()][AllowEmptyString()][Parameter(Mandatory)]$Words,
        [int][Parameter(Mandatory)]$WordPosition,
        [string][AllowEmptyString()][Parameter(Mandatory)]$CurrentWord,
        [string][AllowEmptyString()][Parameter(Mandatory)]$PreviousWord
    )
    
    WriteLog "CursorPosition=$CursorPosition"
    WriteLog "Words=$Words"
    WriteLog "WordPosition=$WordPosition"
    WriteLog "CurrentWord=$CurrentWord"
    WriteLog "PreviousWord=$PreviousWord"

    $script:CursorPosition = $CursorPosition
    $script:Words = $Words
    $script:gitCArgs = $gitCArgs
    $script:command = $command
    $script:commandIndex = $commandIndex
    $script:WordPosition = $WordPosition
    $script:CurrentWord = $CurrentWord
    $script:PreviousWord = $PreviousWord
    
    $script:__git_repo_path = $null
    $script:gitDir = $null
    $script:gitCArgs = @()
    $script:command = ''
    $script:commandIndex = 0

    :globalflag for ($i = 1; $i -lt $script:WordPosition; $i++) {
        $s = $script:Words[$i]
        switch -Wildcard -CaseSensitive ($s) {
            '--git-dir=*' {
                $script:gitDir = [System.IO.DirectoryInfo]::new($s.Substring('--git-dir='.Length))
                continue
            }
            '--git-dir' {
                if (++$i -lt $script:Words.Count) {
                    $script:gitDir = [System.IO.DirectoryInfo]::new($script:Words[$i])
                }
                continue
            }
            '--bare' {
                $script:gitDir = [System.IO.DirectoryInfo]::new('.')
                continue
            }
            '--help' {
                $script:command = 'help'
                break globalflag
            }
            { $_ -cin @('-c', '--work-tree', '--namespace') } {
                ++$i
                continue
            }
            '-C' {
                $script:gitCArgs += @('-C', $script:Words[++$i])
                continue
            }
            '-*' {
                continue
            }
            default {
                $script:command = $s
                $script:commandIndex = $i
                break globalflag
            }
        }
    }
    WriteLog "gitDir=$gitDir"
    WriteLog "gitCArgs=$gitCArgs"
    WriteLog "command=$command"
    WriteLog "commandIndex=$commandIndex"

    if ($command) {
        return CompleteSubCommands
    }

    switch -Wildcard -CaseSensitive ($PreviousWord) {
        { $_ -cin @('-C', '--work-tree', '--git-dir') } {
            # these need a path argument
            return
        }
        '-c' {
            completeConfigVariableNameAndValue -Current $CurrentWord
            return
        }
        '--namespace' {
            # we don't support completing these options' arguments
            return
        }
    }

    switch -Wildcard ($CurrentWord) {
        '--*' {
            $gitGlobalOptions | ForEach-Object { $_.ToLongCompletion($CurrentWord) } | Where-Object { $_ }
            return
        }
        '-' {
            $gitGlobalOptions | ForEach-Object { $_.ToShortCompletion() } | Where-Object { $_ }
            return
        }
    }
    # case "$cur" in
    # --*)
    #     __gitcomp "
    #     --paginate
    #     --no-pager
    #     --git-dir=
    #     --bare
    #     --version
    #     --exec-path
    #     --exec-path=
    #     --html-path
    #     --man-path
    #     --info-path
    #     --work-tree=
    #     --namespace=
    #     --no-replace-objects
    #     --help
    #     "
    #     ;;
    # *)
    #     if test -n "${GIT_TESTING_PORCELAIN_COMMAND_LIST-}"
    #     then
    #         __gitcomp "$GIT_TESTING_PORCELAIN_COMMAND_LIST"
    #     else
    #         local list_cmds=list-mainporcelain,others,nohelpers,alias,list-complete,config

    #         if test "${GIT_COMPLETION_SHOW_ALL_COMMANDS-}" = "1"
    #         then
    #             list_cmds=builtins,$list_cmds
    #         fi
    #         __gitcomp "$(__git --list-cmds=$list_cmds)"
    #     fi
    #     ;;
    # esac
}
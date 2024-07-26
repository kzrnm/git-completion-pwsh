. $PSScriptRoot/GitCommands.ps1
. $PSScriptRoot/GitStatics.ps1
. $PSScriptRoot/CompleteConfig.ps1
. $PSScriptRoot/CompleteSubCommands.ps1

function WriteLog {
    param([Parameter(Position = 0)]$Object)
    
    if ($env:GitCompletionDubugPath) {
        $Object >> $env:GitCompletionDubugPath
    }
}

# __git_main
function Initialize-GitComplete {
    param(
        [System.Management.Automation.Language.CommandAst]
        $CommandAst,
        [int]
        $CursorPosition
    )

    if ($env:GitCompletionDubugPath -and (-not $env:GitCompletionDubugKeep)) {
        $null > $env:GitCompletionDubugPath
    }

    $script:__git_repo_path = $null
    $script:CommandAst = $CommandAst
    $script:CursorPosition = $CursorPosition
    $script:Words = ($CommandAst.CommandElements | Select-Object -ExpandProperty Extent | Select-Object -ExpandProperty Text)

    $script:gitDir = $null
    $script:gitCArgs = @()
    $script:command = ''
    $script:commandIndex = 0

    $cw = $CommandAst.CommandElements.Count
    $pr = $script:Words[$script:Words.Count - 1]
    $cr = ''

    for ($i = 1; $i -lt $CommandAst.CommandElements.Count; $i++) {
        $extent = $script:CommandAst.CommandElements[$i].Extent

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

    WriteLog "CommandAst=$CommandAst"
    WriteLog "CursorPosition=$CursorPosition"
    WriteLog "Words=$Words"
    WriteLog "gitCArgs=$gitCArgs"
    WriteLog "command=$command"
    WriteLog "commandIndex=$commandIndex"
    WriteLog "WordPosition=$WordPosition"
    WriteLog "CurrentWord=$CurrentWord"
    WriteLog "PreviousWord=$PreviousWord"
    WriteLog "gitDir=$gitDir"
}

function GitComplete {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param()
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

    # TODO: 作成中
    return $null
}
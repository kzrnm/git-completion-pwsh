# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
param([string]$Line)

Import-Module "$PSScriptRoot/../src/git-completion.psd1" -Force

function Complete-FromLine {
    param (
        [string][Parameter(ValueFromPipeline)] $line,
        [string]$Right = ' '
    )

    switch -Wildcard ($line) {
        'gitk *' {
            Set-Alias Complete Complete-Gitk -Scope Local
            break
        }
        'git *' {
            Set-Alias Complete Complete-Git -Scope Local
            break
        }
        Default { throw 'Invalid input' }
    }

    $CommandAst = [System.Management.Automation.Language.Parser]::ParseInput($line + $Right, [ref]$null, [ref]$null).EndBlock.Statements.PipelineElements
    $CursorPosition = $line.Length
    return (Complete -CommandAst $CommandAst -CursorPosition $CursorPosition)
}

$Line | Complete-FromLine
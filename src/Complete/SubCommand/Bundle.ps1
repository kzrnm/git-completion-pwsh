# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-bundle {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $result = Complete-GitSubCommandCommon $Context
    if ($result) { return $result }

    if ($Context.SubcommandWithoutGlobalOption() -eq 'create') {
        if ($Context.DoubledashIndex -lt ($Context.CurrentIndex - 1)) {
            return gitCompleteRevlist $Context.CurrentWord()
        }

        for ($i = $Context.CommandIndex + 2; $i -lt $Context.CurrentIndex; $i++) {
            switch -Wildcard ($Context.Words[$i]) {
                '-*' { }
                Default { 
                    gitCompleteRevlist $Context.CurrentWord()
                }
            }
        }
        return
    }
}
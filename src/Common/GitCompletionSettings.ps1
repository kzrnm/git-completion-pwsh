# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace Kzrnm.GitCompletion;

$script:GitCompletionSettings = [GitCompletionSettings]::EnvDefault()

function listCommands {
    param()
    
    $commands = [HashSet[string]]::new()
    $cmds = @('builtins', 'list-mainporcelain', 'others', 'nohelpers', 'alias', 'list-complete', 'config')
    if (!$script:GitCompletionSettings.ShowAllCommand) {
        $cmds = $cmds | Select-Object -Skip 1
    }
    gitAllCommands @cmds | ForEach-Object { $commands.Add($_) } > $null

    if ($script:GitCompletionSettings.AdditionalCommands) {
        $commands.UnionWith([string[]]@($script:GitCompletionSettings.AdditionalCommands)) 
    }
    if ($script:GitCompletionSettings.ExcludeCommands) {
        $commands.ExceptWith([string[]]@($script:GitCompletionSettings.ExcludeCommands))
    }

    return $commands | Sort-Object
}
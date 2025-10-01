# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

class GitCompletionSettings {
    [bool] $ShowAllOptions;
    [bool] $ShowAllCommand;
    [bool] $IgnoreCase;
    [bool] $CheckoutNoGuess;

    [string[]] $AdditionalCommands;
    [string[]] $ExcludeCommands;

    [int] $CommitMessageFetchThreshold;
}

[GitCompletionSettings]$script:GitCompletionSettings = @{
    ShowAllOptions              = ($env:GIT_COMPLETION_SHOW_ALL -and ($env:GIT_COMPLETION_SHOW_ALL -ne '0'));
    ShowAllCommand              = ($env:GIT_COMPLETION_SHOW_ALL_COMMANDS -and ($env:GIT_COMPLETION_SHOW_ALL_COMMANDS -ne '0'));
    IgnoreCase                  = ($env:GIT_COMPLETION_IGNORE_CASE -and ($env:GIT_COMPLETION_IGNORE_CASE -ne '0'));
    CheckoutNoGuess             = ($env:GIT_COMPLETION_CHECKOUT_NO_GUESS -and ($env:GIT_COMPLETION_CHECKOUT_NO_GUESS -ne '0'));

    AdditionalCommands          = [string[]]@()
    ExcludeCommands             = [string[]]@()

    CommitMessageFetchThreshold = 100;
}

function listCommands {
    param()
    
    $commands = [HashSet[string]]::new()
    $cmds = @('builtins', 'list-mainporcelain', 'others', 'nohelpers', 'alias', 'list-complete', 'config')
    if (!$script:GitCompletionSettings.ShowAllCommand) {
        $cmds = $cmds | Select-Object -Skip 1
    }
    gitAllCommands @cmds | ForEach-Object { $commands.Add($_) } > $null

    $commands.UnionWith([string[]]@($script:GitCompletionSettings.AdditionalCommands))
    $commands.ExceptWith([string[]]@($script:GitCompletionSettings.ExcludeCommands))

    return $commands | Sort-Object
}
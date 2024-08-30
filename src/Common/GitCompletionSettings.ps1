using namespace System.Collections.Generic;

$script:GitCompletionSettings = [PSCustomObject]@{
    ShowAllOptions     = ($env:GIT_COMPLETION_SHOW_ALL -and ($env:GIT_COMPLETION_SHOW_ALL -ne '0'));
    ShowAllCommand     = ($env:GIT_COMPLETION_SHOW_ALL_COMMANDS -and ($env:GIT_COMPLETION_SHOW_ALL_COMMANDS -ne '0'));
    IgnoreCase         = ($env:GIT_COMPLETION_IGNORE_CASE -and ($env:GIT_COMPLETION_IGNORE_CASE -ne '0'));

    AdditionalCommands = [string[]]@()
    ExcludeCommands    = [string[]]@()
}

function listCommands {
    param()
    
    $commands = [HashSet[string]]::new()
    $cmds = @('builtins', 'list-mainporcelain', 'others', 'nohelpers', 'alias', 'list-complete', 'config')
    if (!$script:GitCompletionSettings.ShowAllCommand) {
        $cmds = $cmds | Select-Object -Skip 1
    }
    gitAllCommands @cmds | ForEach-Object { $commands.Add($_) } | Out-Null

    foreach ($c in $script:GitCompletionSettings.AdditionalCommands) {
        $commands.Add($c)
    }
    foreach ($c in $script:GitCompletionSettings.ExcludeCommands) {
        $commands.Remove($c)
    }

    return $commands | Sort-Object
}
using namespace System.Collections.Generic;

$script:__gitSubcommandInclude = $null
$script:__gitSubcommandExclude = $null

function Add-GitSubcommand {
    <#
    .SYNOPSIS
        Force display the subcommand
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments)]
        [string[]]
        $Candidate
    )

    foreach ($c in $Candidate) {
        addOrRemoveSubcommand -Candidate $c -add ([ref]$script:__gitSubcommandInclude) -remove ([ref]$script:__gitSubcommandExclude) 
    }
}

function Remove-GitSubcommand {
    <#
    .SYNOPSIS
        Force remove the subcommand
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments)]
        [string[]]
        $Candidate
    )

    foreach ($c in $Candidate) {
        addOrRemoveSubcommand -Candidate $c -remove ([ref]$script:__gitSubcommandInclude) -add ([ref]$script:__gitSubcommandExclude)
    }

}

function addOrRemoveSubcommand {
    param (
        [Parameter(Mandatory)]
        [string]
        $Candidate,
        [ref] $add,
        [ref] $remove
    )

    if (-not $add.Value) {
        $add.Value = [HashSet[string]]::new()
    }
    $add.Value.Add($Candidate) | Out-Null

    if ($remove.Value) {
        $remove.Value.Remove($Candidate) | Out-Null
    }
}

function filterSubcommandExclude {
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $Command
    )

    process {
        if ($script:__gitSubcommandExclude -and $script:__gitSubcommandExclude.Contains($Command)) {
            return
        }
        $Command
    }
}


function listCommands {
    param()

    $commands = [List[string]]::new()
    gitAllCommands list-mainporcelain others nohelpers alias list-complete config | filterSubcommandExclude | ForEach-Object { $commands.Add($_) } | Out-Null

    if ($script:__gitSubcommandInclude) {
        $commands.AddRange($script:__gitSubcommandInclude)
    }

    $commands.Sort()

    if (isGitCompletionShowAllCommand) {
        $commandsSet = [HashSet[string]]::new($commands)
        $commands.AddRange([string[]]@(gitBuiltinCommands | filterSubcommandExclude | Where-Object { -not $commandsSet.Contains($_) } | Sort-Object -Unique))
    }

    return $commands.ToArray()
}
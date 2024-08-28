using namespace System.Management.Automation;

function Complete-GitSubCommand-push {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        # [CommandLineContext] # For dynamic call
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Prev = $Context.PreviousWord()
    [string] $Current = $Context.CurrentWord()

    if ($Current -eq '-') {
        return Get-GitShortOptions $Context.command
    }

    switch ($Prev) {
        '--repo' {
            gitRemote | completeList -Current $Current -ResultType ParameterValue 
            return
        }
        '--recurse-submodules' {
            $script:gitPushRecurseSubmodules | completeList -Current $Current -ResultType ParameterValue 
            return
        }
    }

    switch -Wildcard ($Current) {
        '--repo=*' { 
            gitRemote | completeList -Current $Current -ResultType ParameterValue -Prefix '--repo=' -RemovePrefix
            return
        }
        '--recurse-submodules=*' { 
            $script:gitPushRecurseSubmodules | completeList -Current $Current -ResultType ParameterValue -Prefix '--recurse-submodules=' -RemovePrefix
            return
        }
        '--force-with-lease=*' {
            $c = $Current.Substring('--force-with-lease='.Length)
            if ($c.StartsWith('--')) { }
            elseif ($c -like '*:*') {
                ($left, $right) = $c -split ":", 2
                gitCompleteRefs -Current $right -Prefix "--force-with-lease=${left}:"
            }
            else {
                gitCompleteRefs -Current $c -Prefix '--force-with-lease='
            }
            return
        }
        '--*' {
            gitCompleteResolveBuiltins $Context.command -Current $Current
            return
        }
    }
    gitCompleteRemoteOrRefspec $Context
}

function gitCompleteForceWithLease() {
    [OutputType([string[]])]
    param(
        [string]
        $Current
    )
    
    if ($Current.StartsWith('--')) { return @() }
    elseif ($Current -match '(.*):(.*)') { 
        gitCompleteRefs -Current $Matches[2] -Prefix ($Matches[1] + ':')
    }
    else {
        gitCompleteRefs -Current $Current
    }
}
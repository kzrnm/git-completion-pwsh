using namespace System.Management.Automation;

function Complete-GitSubCommand-pull {
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

    $result = gitCompleteStrategy -Current $Current -Prev $Prev
    if ($null -ne $result) { return $result }

    
    switch ($Prev) {
        '--recurse-submodules' {
            $script:gitFetchRecurseSubmodules | completeList -Current $Current -ResultType ParameterValue 
            return
        }
    }

    switch -Wildcard ($Current) {
        '--recurse-submodules=*' { 
            $script:gitFetchRecurseSubmodules | completeList -Current $Current -ResultType ParameterValue -Prefix '--recurse-submodules=' -RemovePrefix
            return
        }
        '--*' {
            gitResolveBuiltins $Context.command | gitcomp -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $_ $Context.command }
            return
        }
    }

    gitCompleteRemoteOrRefspec $Context
}
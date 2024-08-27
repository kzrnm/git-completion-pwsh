using namespace System.Management.Automation;

function Complete-GitSubCommand-fetch {
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

    $gitFetchFilters = "blob:none", "blob:limit=", "sparse:oid="
    switch ($Prev) {
        '--recurse-submodules' {
            $script:gitFetchRecurseSubmodules | completeList -Current $Current -ResultType ParameterValue 
            return
        }
        '--filter' {
            $gitFetchFilters | completeList -Current $Current -ResultType ParameterValue 
            return
        }
    }

    switch -Wildcard ($Current) {
        '--recurse-submodules=*' { 
            $script:gitFetchRecurseSubmodules | completeList -Current $Current -ResultType ParameterValue -Prefix '--recurse-submodules=' -RemovePrefix
            return
        }
        '--filter=*' {
            $gitFetchFilters | completeList -Current $Current -ResultType ParameterValue -Prefix '--filter=' -RemovePrefix
            return
        }
        '--*' {
            gitResolveBuiltins $Context.command | gitcomp -Current $Current -DescriptionBuilder { Get-GitOptionsDescription $Context.command  $_ }
            return
        }
    }
    gitCompleteRemoteOrRefspec $Context
}
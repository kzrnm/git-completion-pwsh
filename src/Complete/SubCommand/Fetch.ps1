using namespace System.Management.Automation;

function Complete-GitSubCommand-fetch {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Prev = $Context.PreviousWord()
    [string] $Current = $Context.CurrentWord()
    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.command -Current $Current
        if ($shortOpts) { return $shortOpts }

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
                gitCompleteResolveBuiltins $Context.command -Current $Current
                return
            }
        }
    }
    gitCompleteRemoteOrRefspec $Context
}
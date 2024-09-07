using namespace System.Management.Automation;

function Complete-GitSubCommand-pull {
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
                gitCompleteResolveBuiltins $Context.command -Current $Current
                return
            }
        }
    }

    gitCompleteRemoteOrRefspec $Context
}
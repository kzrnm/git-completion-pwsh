using namespace System.Management.Automation;

function Complete-GitSubCommand-clone {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.command -Current $Current
        if ($shortOpts) { return $shortOpts }

        if ($Context.PreviousWord() -cmatch '^-([^-]*c|-config)$') {
            completeConfigOptionVariableNameAndValue $Current
            return
        }

        if ($prevCandidates) {
            $prevCandidates | completeList -Current $Current -ResultType ParameterValue
            return
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            switch -CaseSensitive ($key) {
                '--config' {
                    completeConfigOptionVariableNameAndValue $value
                    return
                }
            }
        }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.command -Current $Current
            return
        }
    }
}
using namespace System.Management.Automation;

function Complete-GitSubCommand-difftool {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if ($Current -eq '-') {
        return Get-GitShortOptions $Context.command
    }

    $prevCandidates = switch ($Context.PreviousWord()) {
        '--tool' { ($gitMergetoolsCommon + @('kompare')) }
    }

    if ($prevCandidates) {
        $prevCandidates | completeList -Current $Current -ResultType ParameterValue
        return
    }

    if ($Current -cmatch '(--[^=]+)=.*') {
        $key = $Matches[1]
        $candidates = switch ($key) {
            '--tool' { ($gitMergetoolsCommon + @('kompare')) }
        }

        if ($candidates) {
            $candidates | completeList -Current $Current -Prefix "$key=" -ResultType ParameterValue -RemovePrefix
            return
        }
    }

    if ($Current.StartsWith('--')) {
        $gitDiffDifftoolOptions | completeList -Current $Current
        gitCompleteResolveBuiltins $Context.command -Current $Current
        return
    }

    gitCompleteRevlistFile $Current
}
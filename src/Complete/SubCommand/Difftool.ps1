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

    if ($Context.PreviousWord() -eq '--tool') {
        ($gitMergetoolsCommon + @('kompare')) | completeList -Current $Current -ResultType ParameterValue
        return
    }

    switch -Wildcard ($Current) {
        '--tool=*' {
            ($gitMergetoolsCommon + @('kompare')) | completeList -Current $Current -Prefix "--tool=" -ResultType ParameterValue -RemovePrefix
            return
        }
        '--*' {
            $gitDiffDifftoolOptions | completeList -Current $Current
            gitCompleteResolveBuiltins $Context.command -Current $Current
            return
        }
    }
    gitCompleteRevlistFile $Current
}
using namespace System.Management.Automation;

function Complete-GitSubCommand-mergetool {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()

    if ($Current -eq '-') {
        return @(
            [CompletionResult]::new(
                '-g',
                '-g',
                'ParameterName',
                "--gui"
            ),
            [CompletionResult]::new(
                '-O',
                '-O',
                'ParameterName',
                "Process files in the order specified"
            ),
            [CompletionResult]::new(
                '-y',
                '-y',
                'ParameterName',
                "Don’t prompt before each invocation of the merge resolution program"
            ),
            $__helpCompletion
        )
    }

    if ($Context.PreviousWord() -eq '--tool') {
        ($gitMergetoolsCommon + @('tortoisemerge')) | completeList -Current $Current -ResultType ParameterValue
        return
    }

    if (!$Current.StartsWith('--')) { return @() }

    switch -Wildcard ($Current) {
        '--tool=*' {
            ($gitMergetoolsCommon + @('tortoisemerge')) | completeList -Current $Current -Prefix "--tool=" -ResultType ParameterValue -RemovePrefix
            return
        }
        '--*' {
            '--tool=', '--prompt', '--no-prompt', '--gui', '--no-gui' | completeList -Current $Current
            return
        }
    }
}